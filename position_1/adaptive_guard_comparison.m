% adaptive_guard_comparison.m
% Сравнение трёх подходов к guard-зоне в OTFS:
%   1. Reduced guard  — L_g_dopp=4, L_g_delay=6  (минимальная)
%   2. Full guard     — L_g_dopp=10, L_g_delay=14 (фиксированная, Raviteja)
%   3. Adaptive guard — оптимизированная под scenario (предложенный метод)
%
% Ключевая идея:
% - Delay guard определяется delay spread канала (scenario-dependent)
% - Doppler guard определяется Doppler spread + sidelobes
% - FRFT-SIC компенсирует остаточную интерференцию

clear; close all; clc;

%% ============================================================
%  Параметры OTFS (из положения 3)
% ============================================================
M = 64;           % Поднесущие
N = 32;           % Допплер-бины
df = 150e3;       % Межподнесущий интервал, Гц
fc = 5.9e9;       % Несущая частота, Гц
T = 1/df;         % Длительность поднесущего символа
pilot_power = 100;
pilot_amp = sqrt(pilot_power);

%% ============================================================
%  Сценарии (3GPP 38.901)
% ============================================================
scenarios = struct(...
    'name',  {'UMi_NLOS', 'UMa_NLOS', 'RMa_NLOS'}, ...
    'tau90', {1.0e-6,   3.0e-6,   5.0e-6});

speeds = [10, 30, 50, 80, 120, 150, 200]; % м/с

%% ============================================================
%  Fixed guard zones
% ============================================================
guard_reduced = struct('dopp', 4, 'delay', 6);
guard_full     = struct('dopp', 10, 'delay', 14);

%% ============================================================
%  Расчёт
% ============================================================
fprintf('=== Сравнение guard-зон: Reduced vs Full vs Adaptive ===\n\n');
fprintf('%-12s %5s %8s %6s %7s %6s %6s %7s %9s %8s\n', ...
    'Scenario', 'v', 'Method', 'L_g_d', 'L_g_dl', 'Guard', 'Data', 'Eff.%', 'I_pilot', 'SNR_req');
fprintf('%s\n', repmat('-', 1, 90));

results = struct();

for si = 1:length(scenarios)
    sc = scenarios(si);

    for vi = 1:length(speeds)
        v = speeds(vi);
        [L_ad_d, L_ad_dl] = compute_adaptive_guard(sc, v, M, N, df, fc);

        key = sprintf('%s_v%d', sc.name, v);
        results.(key).scenario = sc.name;
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
                sc.name, v, name, L_d, L_dl, N_guard, N_data, efficiency, I_pilot, SNR_req);
        end
    end
    fprintf('\n');
end

%% ============================================================
%  Визуализация
% ============================================================
output_dir = fileparts(mfilename('fullpath'));
colors = lines(3);

% --- Figure 1: Guard zone sizes vs speed ---
figure('Position', [100, 100, 900, 600]);

for si = 1:length(scenarios)
    sc = scenarios(si);
    subplot(2, 2, si);

    L_d_ad = zeros(size(speeds));
    L_dl_ad = zeros(size(speeds));

    for vi = 1:length(speeds)
        key = sprintf('%s_v%d', sc.name, speeds(vi));
        L_d_ad(vi) = results.(key).Adaptive.L_g_dopp;
        L_dl_ad(vi) = results.(key).Adaptive.L_g_delay;
    end

    plot(speeds, L_d_ad, '^-', 'Color', colors(3,:), 'LineWidth', 2, 'MarkerSize', 8); hold on;
    plot(speeds, L_dl_ad, 's-', 'Color', colors(3,:), 'LineWidth', 2, 'MarkerSize', 8);
    yline(guard_full.dopp, '--', 'Color', colors(2,:), 'Label', 'L_g_dopp Full');
    yline(guard_full.delay, ':', 'Color', colors(2,:), 'Label', 'L_g_delay Full');
    yline(guard_reduced.dopp, '-.', 'Color', colors(1,:), 'Label', 'L_g_dopp Reduced');
    yline(guard_reduced.delay, ':', 'Color', colors(1,:), 'Label', 'L_g_delay Reduced');

    xlabel('Скорость, м/с');
    ylabel('L_{guard}');
    title(sc.name);
    grid on;
end

sgtitle('Guard-zone sizes: Reduced vs Full vs Adaptive');
saveas(gcf, fullfile(output_dir, 'fig_guard_vs_speed.png'));

% --- Figure 2: Spectral efficiency vs speed ---
figure('Position', [100, 100, 900, 400]);

for si = 1:length(scenarios)
    sc = scenarios(si);
    subplot(1, 3, si);

    eff_r = zeros(size(speeds));
    eff_f = zeros(size(speeds));
    eff_a = zeros(size(speeds));

    for vi = 1:length(speeds)
        key = sprintf('%s_v%d', sc.name, speeds(vi));
        eff_r(vi) = results.(key).Reduced.efficiency;
        eff_f(vi) = results.(key).Full.efficiency;
        eff_a(vi) = results.(key).Adaptive.efficiency;
    end

    plot(speeds, eff_r, 'o--', 'Color', colors(1,:), 'LineWidth', 1.5, 'MarkerSize', 6); hold on;
    plot(speeds, eff_f, 's--', 'Color', colors(2,:), 'LineWidth', 1.5, 'MarkerSize', 6);
    plot(speeds, eff_a, '^-', 'Color', colors(3,:), 'LineWidth', 2, 'MarkerSize', 8);

    xlabel('Скорость, м/с');
    ylabel('Spectral efficiency, %');
    title(sc.name);
    legend('Reduced', 'Full', 'Adaptive', 'Location', 'southwest');
    grid on;
end

sgtitle('Spectral efficiency vs speed');
saveas(gcf, fullfile(output_dir, 'fig_efficiency_vs_speed.png'));

% --- Figure 3: Gain Adaptive vs Full ---
figure('Position', [100, 100, 900, 300]);

for si = 1:length(scenarios)
    sc = scenarios(si);
    subplot(1, 3, si);

    gain = zeros(size(speeds));
    for vi = 1:length(speeds)
        key = sprintf('%s_v%d', sc.name, speeds(vi));
        gain(vi) = results.(key).Adaptive.efficiency - results.(key).Full.efficiency;
    end

    bar(speeds, gain, 'FaceColor', colors(3,:));
    xlabel('Скорость, м/с');
    ylabel('\Delta Efficiency, %');
    title(sc.name);
    grid on;
    yline(0, 'k--');
end

sgtitle('Gain: Adaptive vs Full');
saveas(gcf, fullfile(output_dir, 'fig_adaptive_gain.png'));

%% ============================================================
%  Summary
% ============================================================
fprintf('\n=== SUMMARY: Adaptive vs Full ===\n\n');

for si = 1:length(scenarios)
    sc = scenarios(si);
    better = 0; worse = 0;
    for vi = 1:length(speeds)
        key = sprintf('%s_v%d', sc.name, speeds(vi));
        eff_a = results.(key).Adaptive.efficiency;
        eff_f = results.(key).Full.efficiency;
        if eff_a > eff_f
            better = better + 1;
        else
            worse = worse + 1;
        end
    end
    fprintf('%s: Adaptive better %d/%d, worse %d/%d\n', ...
        sc.name, better, length(speeds), worse, length(speeds));
end

fprintf('\nРезультаты сохранены в adaptive_guard_results.mat\n');
save(fullfile(output_dir, 'adaptive_guard_results.mat'), 'results');
fprintf('Фигуры сохранены.\n');

%% ============================================================
%  Local functions
% ============================================================
function [L_g_dopp, L_g_delay] = compute_adaptive_guard(scenario, v, M, N, df, fc)
    tau_90 = scenario.tau90;

    % Разрешение
    dtau = 1 / (M * df);
    dnu = df / N;

    % Delay guard
    tau_tilde_90 = tau_90 / dtau;
    M_sidelobe = 4;
    L_g_delay = max(1, min(ceil(tau_tilde_90) + M_sidelobe, floor(M/2) - 1));

    % Doppler guard
    f_dopp = fc * v / 3e8;
    nu_spread = 2 * f_dopp / dnu;
    N_sidelobe = 7;  % FRFT-SIC компенсирует остаток
    L_g_dopp = max(1, min(ceil(nu_spread) + N_sidelobe, floor(N/2) - 1));
end
