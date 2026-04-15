% adaptive_guard_quadriga.m
% Сравнение guard-зон на основе РЕАЛЬНЫХ каналов QuaDRiGa (3GPP 38.901)
%
% Ключевое отличие от предыдущей версии:
% - Delay spread извлекается из сгенерированных каналов (не из таблиц)
% - Doppler spread вычисляется из скорости и сценария
% - Adaptive guard опирается на фактические параметры канала
%
% QuaDRiGa путь: documentation/quadriga_src/
% Tutorials: documentation/tutorials/

clear; close all; clc;

%% ============================================================
%  Добавляем QuaDRiGa в путь
% ============================================================
proj_root = fileparts(fileparts(mfilename('fullpath')));
quadriga_path = fullfile(proj_root, 'documentation', 'quadriga_src');
addpath(quadriga_path);

%% ============================================================
%  Параметры OTFS
% ============================================================
M = 64;           % Поднесущие
N = 32;           % Допплер-бины
df = 150e3;       % Межподнесущий интервал, Гц
fc = 5.9e9;       % Несущая частота, Гц
T = 1/df;         % Длительность поднесущего символа
pilot_power = 100;
pilot_amp = sqrt(pilot_power);

% Разрешение DD-сетки
dtau = 1 / (M * df);   % ~104 нс
dnu = df / N;          % ~4.69 кГц

%% ============================================================
%  Сценарии QuaDRiGa (3GPP 38.901)
% ============================================================
scenarios = {
    '3GPP_38.901_UMi_NLOS',  'UMi_NLOS';
    '3GPP_38.901_UMa_NLOS',  'UMa_NLOS';
    '3GPP_38.901_RMa_NLOS',  'RMa_NLOS'
};

speeds = [10, 30, 50, 80, 120, 150, 200]; % м/с

%% ============================================================
%  Fixed guard zones
% ============================================================
guard_reduced = struct('dopp', 4, 'delay', 6);
guard_full     = struct('dopp', 10, 'delay', 14);

%% ============================================================
%  Генерация каналов QuaDRiGa и извлечение параметров
% ============================================================
fprintf('=== Генерация каналов QuaDRiGa ===\n\n');

% Параметры симуляции QuaDRiGa
s = qd_simulation_parameters;
s.center_frequency = fc;
s.show_progress_bars = 0;
s.use_absolute_delays = 1;

% Для каждого сценария генерируем каналы и извлекаем delay spread
quadriga_results = struct();

for si = 1:size(scenarios, 1)
    scen_name = scenarios{si, 1};
    short_name = scenarios{si, 2};

    fprintf('--- %s ---\n', short_name);

    % Создаём layout с одним TX и множеством RX
    l = qd_layout(s);
    l.no_rx = 100;  % 100 приёмников для статистики
    l.randomize_rx_positions(200, 1.5, 1.5, 1.7);  % 200м радиус, 1.5м высота
    l.set_scenario(scen_name);

    l.tx_position(3) = 25;  % Высота TX 25м
    l.tx_array = qd_arrayant('omni');
    l.rx_array = qd_arrayant('omni');

    % Инициализируем builder
    p = l.init_builder;
    p.plpar = [];  % Отключаем path-loss (нам нужны только multipath параметры)
    p.scenpar.NumClusters = 15;  % Ограничиваем число кластеров

    % Генерируем параметры и каналы
    p.gen_parameters;
    c = p.get_channels;

    % Извлекаем delays и powers из всех каналов
    all_tau_90 = [];
    for ri = 1:l.no_rx
        delays = cat(5, c(ri).delay);    % [ant_tx, ant_rx, path, snap]
        powers = cat(5, c(ri).coeff);

        % Усредняем power по snapshot-ам и антеннам
        pow = squeeze(mean(mean(abs(powers).^2, 1), 1));  % [path]
        tau = squeeze(mean(mean(delays, 1), 1));           % [path]

        if isempty(pow) || isempty(tau)
            continue;
        end

        % Сортируем по delay
        [tau_sorted, idx] = sort(tau);
        pow_sorted = pow(idx);

        % Находим tau_90: delay, в котором накоплено 90%% энергии
        cum_pow = cumsum(pow_sorted);
        total_pow = cum_pow(end);
        if total_pow == 0
            continue;
        end
        tau_90_idx = find(cum_pow >= 0.9 * total_pow, 1);
        tau_90 = tau_sorted(tau_90_idx) - tau_sorted(1);

        all_tau_90 = [all_tau_90; tau_90];
    end

    % Статистика tau_90 по всем RX
    median_tau_90 = median(all_tau_90);
    p90_tau_90 = prctile(all_tau_90, 90);

    fprintf('  median tau_90 = %.2f мкс\n', median_tau_90 * 1e6);
    fprintf('  p90   tau_90  = %.2f мкс\n', p90_tau_90 * 1e6);

    quadriga_results.(short_name).median_tau_90 = median_tau_90;
    quadriga_results.(short_name).p90_tau_90 = p90_tau_90;
    quadriga_results.(short_name).all_tau_90 = all_tau_90;
    fprintf('\n');
end

%% ============================================================
%  Расчёт сравнения
% ============================================================
fprintf('=== Сравнение guard-зон (QuaDRiGa-based) ===\n\n');
fprintf('%-12s %5s %8s %6s %7s %6s %6s %7s %9s %8s\n', ...
    'Scenario', 'v', 'Method', 'L_g_d', 'L_g_dl', 'Guard', 'Data', 'Eff.%', 'I_pilot', 'SNR_req');
fprintf('%s\n', repmat('-', 1, 90));

results = struct();

for si = 1:size(scenarios, 1)
    sc_short = scenarios{si, 2};
    med_tau = quadriga_results.(sc_short).median_tau_90;

    for vi = 1:length(speeds)
        v = speeds(vi);
        [L_ad_d, L_ad_dl] = compute_adaptive_guard_quadriga(med_tau, v, M, N, df, fc);

        key = sprintf('%s_v%d', sc_short, v);
        results.(key).scenario = sc_short;
        results.(key).v = v;

        methods = {
            'Reduced',  guard_reduced.dopp,  guard_reduced.delay;
            'Full',     guard_full.dopp,     guard_full.delay;
            'Adaptive', L_ad_d,              L_ad_dl
        };

        for mi = 1:size(methods, 1)
            name = methods{mi, 1};
            L_d = methods{mi, 2};
            L_dl = methods{mi, 3};

            N_guard = (2*L_dl + 1) * (2*L_d + 1) - 1;
            N_data = M * N - 1 - N_guard;
            if N_data < 0
                N_data = 0;
                N_guard = M * N - 1;
            end
            efficiency = N_data / (M * N) * 100;

            I_pilot = pilot_amp / (pi * max(L_d, 0.5));
            SNR_req = 10*log10(1 / I_pilot^2);

            results.(key).(name) = struct(...
                'L_g_dopp', L_d, 'L_g_delay', L_dl, ...
                'N_guard', N_guard, 'N_data', N_data, ...
                'efficiency', efficiency, 'I_pilot', I_pilot, 'SNR_req', SNR_req);

            fprintf('%-12s %5d %8s %6d %7d %6d %6d %6.1f %9.4f %7.1f\n', ...
                sc_short, v, name, L_d, L_dl, N_guard, N_data, efficiency, I_pilot, SNR_req);
        end
    end
    fprintf('\n');
end

%% ============================================================
%  Визуализация
% ============================================================
output_dir = fileparts(mfilename('fullpath'));
colors = lines(3);

% --- Figure 1: Delay guard vs speed (QuaDRiGa-based) ---
figure('Position', [100, 100, 900, 300]);

for si = 1:size(scenarios, 1)
    sc_short = scenarios{si, 2};
    subplot(1, 3, si);

    L_dl_ad = zeros(size(speeds));
    for vi = 1:length(speeds)
        key = sprintf('%s_v%d', sc_short, speeds(vi));
        L_dl_ad(vi) = results.(key).Adaptive.L_g_delay;
    end

    plot(speeds, L_dl_ad, 's-', 'Color', colors(3,:), 'LineWidth', 2, 'MarkerSize', 8); hold on;
    yline(guard_full.delay, '--', 'Color', colors(2,:), 'Label', 'Full');
    yline(guard_reduced.delay, '-.', 'Color', colors(1,:), 'Label', 'Reduced');

    xlabel('Скорость, м/с');
    ylabel('L_{g,delay}');
    title(sc_short);
    legend('Adaptive', 'Full', 'Reduced', 'Location', 'southwest');
    grid on;
end

sgtitle('Delay guard zone: QuaDRiGa-based adaptive');
saveas(gcf, fullfile(output_dir, 'fig_qd_delay_guard.png'));

% --- Figure 2: Doppler guard vs speed ---
figure('Position', [100, 100, 900, 300]);

for si = 1:size(scenarios, 1)
    sc_short = scenarios{si, 2};
    subplot(1, 3, si);

    L_d_ad = zeros(size(speeds));
    for vi = 1:length(speeds)
        key = sprintf('%s_v%d', sc_short, speeds(vi));
        L_d_ad(vi) = results.(key).Adaptive.L_g_dopp;
    end

    plot(speeds, L_d_ad, '^-', 'Color', colors(3,:), 'LineWidth', 2, 'MarkerSize', 8); hold on;
    yline(guard_full.dopp, '--', 'Color', colors(2,:), 'Label', 'Full');
    yline(guard_reduced.dopp, '-.', 'Color', colors(1,:), 'Label', 'Reduced');

    xlabel('Скорость, м/с');
    ylabel('L_{g,dopp}');
    title(sc_short);
    grid on;
end

sgtitle('Doppler guard zone: QuaDRiGa-based adaptive');
saveas(gcf, fullfile(output_dir, 'fig_qd_dopp_guard.png'));

% --- Figure 3: Spectral efficiency vs speed ---
figure('Position', [100, 100, 900, 400]);

for si = 1:size(scenarios, 1)
    sc_short = scenarios{si, 2};
    subplot(1, 3, si);

    eff_r = zeros(size(speeds));
    eff_f = zeros(size(speeds));
    eff_a = zeros(size(speeds));

    for vi = 1:length(speeds)
        key = sprintf('%s_v%d', sc_short, speeds(vi));
        eff_r(vi) = results.(key).Reduced.efficiency;
        eff_f(vi) = results.(key).Full.efficiency;
        eff_a(vi) = results.(key).Adaptive.efficiency;
    end

    plot(speeds, eff_r, 'o--', 'Color', colors(1,:), 'LineWidth', 1.5, 'MarkerSize', 6); hold on;
    plot(speeds, eff_f, 's--', 'Color', colors(2,:), 'LineWidth', 1.5, 'MarkerSize', 6);
    plot(speeds, eff_a, '^-', 'Color', colors(3,:), 'LineWidth', 2, 'MarkerSize', 8);

    xlabel('Скорость, м/с');
    ylabel('Spectral efficiency, %');
    title(sc_short);
    legend('Reduced', 'Full', 'Adaptive', 'Location', 'southwest');
    grid on;
end

sgtitle('Spectral efficiency (QuaDRiGa-based adaptive guard)');
saveas(gcf, fullfile(output_dir, 'fig_qd_efficiency.png'));

% --- Figure 4: Gain Adaptive vs Full ---
figure('Position', [100, 100, 900, 300]);

for si = 1:size(scenarios, 1)
    sc_short = scenarios{si, 2};
    subplot(1, 3, si);

    gain = zeros(size(speeds));
    for vi = 1:length(speeds)
        key = sprintf('%s_v%d', sc_short, speeds(vi));
        gain(vi) = results.(key).Adaptive.efficiency - results.(key).Full.efficiency;
    end

    bar(speeds, gain, 'FaceColor', colors(3,:));
    xlabel('Скорость, м/с');
    ylabel('\Delta Efficiency, %');
    title(sc_short);
    grid on;
    yline(0, 'k--');
end

sgtitle('Gain: Adaptive vs Full (QuaDRiGa-based)');
saveas(gcf, fullfile(output_dir, 'fig_qd_gain.png'));

%% ============================================================
%  Summary
% ============================================================
fprintf('\n=== SUMMARY: Adaptive vs Full (QuaDRiGa-based) ===\n\n');

for si = 1:size(scenarios, 1)
    sc_short = scenarios{si, 2};
    med_tau = quadriga_results.(sc_short).median_tau_90;
    better = 0; worse = 0;
    for vi = 1:length(speeds)
        key = sprintf('%s_v%d', sc_short, speeds(vi));
        eff_a = results.(key).Adaptive.efficiency;
        eff_f = results.(key).Full.efficiency;
        if eff_a > eff_f
            better = better + 1;
        else
            worse = worse + 1;
        end
    end
    fprintf('%s: median tau_90=%.1f мкс, Adaptive better %d/%d, worse %d/%d\n', ...
        sc_short, med_tau*1e6, better, length(speeds), worse, length(speeds));
end

fprintf('\nРезультаты сохранены в adaptive_guard_quadriga.mat\n');
save(fullfile(output_dir, 'adaptive_guard_quadriga.mat'), 'results', 'quadriga_results');
fprintf('Фигуры сохранены.\n');

%% ============================================================
%  Local functions
% ============================================================
function [L_g_dopp, L_g_delay] = compute_adaptive_guard_quadriga(median_tau_90, v, M, N, df, fc)
    % Delay guard: на основе РЕАЛЬНОГО median delay spread из QuaDRiGa
    dtau = 1 / (M * df);
    tau_tilde_90 = median_tau_90 / dtau;
    M_sidelobe = 4;
    L_g_delay = max(1, min(ceil(tau_tilde_90) + M_sidelobe, floor(M/2) - 1));

    % Doppler guard: на основе скорости
    dnu = df / N;
    f_dopp = fc * v / 3e8;
    nu_spread = 2 * f_dopp / dnu;
    N_sidelobe = 7;
    L_g_dopp = max(1, min(ceil(nu_spread) + N_sidelobe, floor(N/2) - 1));
end
