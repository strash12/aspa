% plot_dd_frame.m
% Визуализация структуры OTFS кадра в Delay-Doppler области
%
% Показывает: пилот, guard-зону, данные, и влияние канала (размазывание)

clear; close all; clc;

%% ============================================================
%  Параметры
% ============================================================
M = 64;           % Поднесущие (ось задержки)
N = 32;           % Допплер-бины (ось Допплера)

k_p = N/2;        % Позиция пилота по Допплеру = 16
l_p = M/2;        % Позиция пилота по задержке  = 32

% Три варианта guard-зон
guards = struct(...
    'Reduced',  struct('dopp', 4,  'delay', 6), ...
    'Full',     struct('dopp', 10, 'delay', 14), ...
    'Adaptive', struct('dopp', 8,  'delay', 6));

names = fieldnames(guards);
colors_map = [0.85 0.85 0.85;   % данные (светло-серый)
              0.20 0.60 0.85;   % guard (синий)
              1.00 0.25 0.25];  % пилот (красный)

output_dir = fileparts(mfilename('fullpath'));

%% ============================================================
%  Figure 1: DD-кадр для трёх типов guard-зон
% ============================================================
figure('Position', [50, 50, 1400, 500]);

for gi = 1:length(names)
    gname = names{gi};
    g = guards.(gname);

    % Создаём маску DD-кадра
    frame = ones(N, M) * 0;  % 0 = данные

    % Guard-зона
    k_min = max(1, k_p - g.dopp);
    k_max = min(N, k_p + g.dopp);
    l_min = max(1, l_p - g.delay);
    l_max = min(M, l_p + g.delay);

    frame(k_min:k_max, l_min:l_max) = 1;  % 1 = guard
    frame(k_p, l_p) = 2;                   % 2 = пилот

    subplot(1, 3, gi);

    % Рисуем кадр
    h = imagesc(frame);
    colormap([0.92 0.92 0.92; 0.20 0.60 0.85; 1.00 0.25 0.25]);
    caxis([-0.5 2.5]);

    % Оси
    set(gca, 'XTick', 0:8:M, 'XTickLabel', 0:8:M);
    set(gca, 'YTick', 0:4:N, 'YTickLabel', 0:4:N);
    xlabel('Задержка l (bins)');
    ylabel('Допплер k (bins)');
    title(sprintf('%s: L_d=%d, L_{dl}=%d', gname, g.dopp, g.delay), ...
        'FontWeight', 'bold', 'FontSize', 11);

    % Выделяем пилот рамкой
    rectangle('Position', [l_p-0.5, k_p-0.5, 1, 1], ...
        'EdgeColor', 'k', 'LineWidth', 2);

    % Выделяем guard-зону пунктиром
    rectangle('Position', [l_min-0.5, k_min-0.5, ...
        l_max-l_min+1, k_max-k_min+1], ...
        'EdgeColor', [0.1 0.1 0.5], 'LineWidth', 1.5, ...
        'LineStyle', '--');

    grid off;
    axis equal tight;

    % Аннотация с размерами
    N_guard = (2*g.delay+1) * (2*g.dopp+1) - 1;
    N_data = M*N - 1 - N_guard;
    eff = N_data / (M*N) * 100;

    annotation_text = sprintf(...
        'Guard: %d bins\nData:  %d bins\nEff:   %.1f%%', ...
        N_guard, N_data, eff);

    % Размещаем аннотацию в свободном углу
    if gi == 1
        ax_pos = get(gca, 'Position');
        annotation('textbox', ...
            [ax_pos(1)+0.01, ax_pos(2)+ax_pos(4)-0.18, 0.22, 0.15], ...
            'String', annotation_text, ...
            'FontSize', 9, 'FontName', 'Courier New', ...
            'BackgroundColor', 'white', 'EdgeColor', 'black', ...
            'HorizontalAlignment', 'left');
    end
end

sgtitle('Структура OTFS кадра в Delay-Doppler области (M=64, N=32)', ...
    'FontSize', 13, 'FontWeight', 'bold');

drawnow;
saveas(gcf, fullfile(output_dir, 'fig_dd_frame_structure.png'));
fprintf('Сохранено: fig_dd_frame_structure.png\n');

%% ============================================================
%  Figure 2: Крупный план guard-зоны (Adaptive)
% ============================================================
g = guards.Adaptive;
k_min = max(1, k_p - g.dopp);
k_max = min(N, k_p + g.dopp);
l_min = max(1, l_p - g.delay);
l_max = min(M, l_p + g.delay);

figure('Position', [100, 100, 800, 600]);

% Создаём детализированную маску
zoom_frame = ones(k_max-k_min+1, l_max-l_min+1) * 0;
zoom_frame(k_p-k_min+1, l_p-l_min+1) = 2;  % пилот в центре
zoom_frame(zoom_frame==0) = 1;              % guard вокруг

h = imagesc(zoom_frame);
colormap([0.92 0.92 0.92; 0.20 0.60 0.85; 1.00 0.25 0.25]);
caxis([-0.5 2.5]);

% Подписываем каждый bin
for kk = 1:size(zoom_frame, 1)
    for ll = 1:size(zoom_frame, 2)
        k_abs = k_min + kk - 1;
        l_abs = l_min + ll - 1;
        if k_abs == k_p && l_abs == l_p
            text(ll-0.5, kk-0.5, 'P', ...
                'HorizontalAlignment', 'center', ...
                'VerticalAlignment', 'middle', ...
                'FontSize', 14, 'FontWeight', 'bold', 'Color', 'white');
        end
    end
end

set(gca, 'XTick', 0:size(zoom_frame,2), ...
    'XTickLabel', l_min:l_max);
set(gca, 'YTick', 0:size(zoom_frame,1), ...
    'YTickLabel', k_min:k_max);
xlabel('Задержка l (bins)');
ylabel('Допплер k (bins)');
title(sprintf('Крупный план Adaptive guard-зоны\nL_g_dopp=%d, L_g_delay=%d', ...
    g.dopp, g.delay), 'FontSize', 12, 'FontWeight', 'bold');

grid on;
set(gca, 'GridColor', 'white', 'GridAlpha', 0.5);
axis equal tight;

sgtitle('Детализация guard-зоны (каждый bin виден отдельно)', ...
    'FontSize', 11);

drawnow;
saveas(gcf, fullfile(output_dir, 'fig_dd_guard_zoom.png'));
fprintf('Сохранено: fig_dd_guard_zoom.png\n');

%% ============================================================
%  Figure 3: Влияние канала — "размазывание" пилота
% ============================================================
figure('Position', [100, 100, 1200, 450]);

% Создаём DD-отклик канала (имитация)
Hdd = zeros(N, M);
Hdd(k_p, l_p) = 10;  % пилот

% Добавляем "размазывание" от дробного Допплера и многолучевости
% Основной путь
Hdd(k_p, l_p) = 10;

% Дробный Допплер — размазывание по k
for dk = -3:3
    amp = 10 * exp(-dk^2 / (2*1.5^2));
    Hdd(k_p+dk, l_p) = amp;
end

% Дробная задержка — размазывание по l
for dl = -4:4
    amp = 10 * exp(-dl^2 / (2*2.0^2));
    Hdd(k_p, l_p+dl) = amp;
end

% 2D размазывание (многолучевость)
for dk = -2:2
    for dl = -3:3
        if dk == 0 && dl == 0, continue; end
        amp = 3 * exp(-(dk^2/1.5^2 + dl^2/2.0^2));
        Hdd(k_p+dk, l_p+dl) = amp;
    end
end

% Добавляем шум данных
rng(42);
Hdd_noisy = Hdd;
data_mask = ones(N, M);
% Обнуляем guard-зону и пилот
data_mask(k_min:k_max, l_min:l_max) = 0;
Hdd_noisy = Hdd_noisy + randn(N, M) * 0.3 .* data_mask;

% --- Subplot 1: Идеальный DD-отклик ---
subplot(1, 3, 1);
view_region = Hdd(max(1,k_p-8):min(N,k_p+8), max(1,l_p-16):min(M,l_p+16));
imagesc(20*log10(abs(view_region) + 1e-12));
colormap('jet');
caxis([-20 20]);
colorbar;
title('Идеальный DD-отклик канала', 'FontSize', 11);
xlabel('Задержка l'); ylabel('Допплер k');
grid off;

% --- Subplot 2: С шумом данных ---
subplot(1, 3, 2);
view_region_noisy = Hdd_noisy(max(1,k_p-8):min(N,k_p+8), max(1,l_p-16):min(M,l_p+16));
imagesc(20*log10(abs(view_region_noisy) + 1e-12));
colormap('jet');
caxis([-20 20]);
colorbar;
title('С шумом данных (без guard)', 'FontSize', 11);
xlabel('Задержка l'); ylabel('Допплер k');
grid off;

% --- Subplot 3: С guard-зоной (Adaptive) ---
subplot(1, 3, 3);
Hdd_guarded = Hdd_noisy;
Hdd_guarded(k_min:k_max, l_min:l_max) = Hdd(k_min:k_max, l_min:l_max);  % guard обнуляет шум
view_region_guarded = Hdd_guarded(max(1,k_p-8):min(N,k_p+8), max(1,l_p-16):min(M,l_p+16));
imagesc(20*log10(abs(view_region_guarded) + 1e-12));
colormap('jet');
caxis([-20 20]);
colorbar;

% Рисуем границу guard-зоны
guard_k_local = k_min - max(1,k_p-8) + 1;
guard_l_local = l_min - max(1,l_p-16) + 1;
guard_h = k_max - k_min + 1;
guard_w = l_max - l_min + 1;
rectangle('Position', [guard_l_local-0.5, guard_k_local-0.5, ...
    guard_w, guard_h], ...
    'EdgeColor', 'yellow', 'LineWidth', 2, 'LineStyle', '--');

title('С Adaptive guard-зоной', 'FontSize', 11);
xlabel('Задержка l'); ylabel('Допплер k');
grid off;

sgtitle('Влияние guard-зоны на DD-отклик канала (SNR=20 дБ)', ...
    'FontSize', 12, 'FontWeight', 'bold');

drawnow;
saveas(gcf, fullfile(output_dir, 'fig_dd_channel_smearing.png'));
fprintf('Сохранено: fig_dd_channel_smearing.png\n');

%% ============================================================
%  Figure 4: Полный кадр с тепловой картой канала
% ============================================================
figure('Position', [100, 100, 1000, 500]);

% Создаём полный DD-кадр с данными и каналом
full_Hdd = zeros(N, M);

% Данные (случайные QPSK)
for kk = 1:N
    for ll = 1:M
        if kk >= k_min && kk <= k_max && ll >= l_min && ll <= l_max
            continue;  % guard = 0
        end
        if kk == k_p && ll == l_p
            continue;  % пилот
        end
        full_Hdd(kk, ll) = (randn + 1j*randn) / sqrt(2);
    end
end
full_Hdd(k_p, l_p) = 10;  % пилот

% "Канал" — свёртка с импульсным откликом
% Имитируем размазывание: каждый bin влияет на соседей
H_channel = full_Hdd;
for dk = -2:2
    for dl = -3:3
        if dk == 0 && dl == 0, continue; end
        weight = exp(-(dk^2/2.0^2 + dl^2/3.0^2));
        H_channel = H_channel + weight * circshift(full_Hdd, [dk, dl]);
    end
end

subplot(1, 2, 1);
% Маска: показываем структуру кадра
frame_mask = ones(N, M) * 0.5;  % данные
frame_mask(k_min:k_max, l_min:l_max) = 0.8;  % guard
frame_mask(k_p, l_p) = 1.0;     % пилот

imagesc(frame_mask);
colormap([0.3 0.7 0.3; 0.2 0.6 0.85; 1.0 0.25 0.25]);
caxis([0 1.2]);

% Аннотации
text(l_p+3, k_p, sprintf('  Пилот\n  (k=%d, l=%d)', k_p, l_p), ...
    'FontSize', 10, 'FontWeight', 'bold', 'Color', 'red', ...
    'VerticalAlignment', 'middle');

text(l_max+2, k_p, sprintf('  Guard\n  %d bins', (2*g.delay+1)*(2*g.dopp+1)-1), ...
    'FontSize', 9, 'Color', [0.1 0.1 0.5], ...
    'VerticalAlignment', 'middle');

text(2, k_p+10, sprintf('Данные\n%d bins', M*N-1-(2*g.delay+1)*(2*g.dopp+1)+1), ...
    'FontSize', 9, 'Color', [0.2 0.5 0.2], ...
    'VerticalAlignment', 'middle');

set(gca, 'XTick', 0:8:M, 'XTickLabel', 0:8:M);
set(gca, 'YTick', 0:4:N, 'YTickLabel', 0:4:N);
xlabel('Задержка l (bins)');
ylabel('Допплер k (bins)');
title('Структура DD-кадра (Adaptive guard)', 'FontSize', 12, 'FontWeight', 'bold');
grid off;
axis equal tight;

subplot(1, 2, 2);
imagesc(20*log10(abs(H_channel) + 1e-12));
colormap('jet');
caxis([-15 20]);
colorbar;
set(gca, 'XTick', 0:8:M, 'XTickLabel', 0:8:M);
set(gca, 'YTick', 0:4:N, 'YTickLabel', 0:4:N);
xlabel('Задержка l (bins)');
ylabel('Допплер k (bins)');
title('DD-отклик после канала (с размазыванием)', 'FontSize', 12, 'FontWeight', 'bold');
grid off;
axis equal tight;

sgtitle('OTFS кадр: структура и DD-отклик после канала', ...
    'FontSize', 13, 'FontWeight', 'bold');

drawnow;
saveas(gcf, fullfile(output_dir, 'fig_dd_full_frame.png'));
fprintf('Сохранено: fig_dd_full_frame.png\n');

fprintf('\nВсе фигуры сохранены.\n');
