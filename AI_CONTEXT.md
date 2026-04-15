# AI_CONTEXT — АСПА

## Архитектура
Проект: OTFS система с оценкой канала FRFT-SIC, evaluated на каналах QuaDRiGa (3GPP 38.901).
Цель: публикация академической статьи.

### Положения проекта
| Положение | Тема | Статус |
|---|---|---|
| **Положение 1** | Формирование OTFS кадра (DD-сетка, пилот, guard, модуляция) | Завершено |
| **Положение 2** | Прохождение через канал (QuaDRiGa) | В работе |
| **Положение 3** | Оценка канала FRFT-SIC | Завершено (есть результаты) |

## Структура файлов
```
aspa/
├── position_1/              # Положение 1: формирование кадра
│   ├── POSITION_1_CONTEXT.md
│   ├── ADAPTIVE_GUARD_ZONE.md
│   ├── adaptive_guard_comparison.m   # Сравнение guard-зон (табличные delay spread)
│   ├── adaptive_guard_quadriga.m     # Сравнение guard-зон (QuaDRiGa-based)
│   ├── plot_dd_frame.m               # Визуализация DD-кадра
│   └── fig_*.png                     # Фигуры
├── position_2/              # Положение 2: канал (пусто)
├── position_3/              # Положение 3: FRFT-SIC
│   └── PROJECT_CONTEXT.md
├── documentation/
│   ├── quadriga_src/        # Исходники QuaDRiGa v2.8.1
│   ├── tutorials/           # 15 tutorials по QuaDRiGa
│   ├── quadriga_documentation_v2.8.1-0.pdf
│   └── LITERATURE_REVIEW.md
├── run_matlab.bat
├── AI_CONTEXT.md
├── activity.md
└── hot_cache.md
```

## Ключевые решения

### OTFS параметры (FINAL)
- M=64, N=32, df=150 кГц, fc=5.9 ГГц
- Пилот: (k_p=16, l_p=32), pilot_power=100
- Модуляция: QPSK
- Zero Padding: padLen=12

### Adaptive guard-зона (QuaDRiGa-based)
- Delay spread извлекается из РЕАЛЬНЫХ каналов QuaDRiGa (median по 100 RX)
- Doppler guard зависит от скорости
- Результаты (Adaptive vs Full):
  - UMi_NLOS: tau_90=0.20 мкс, L_g=[8,6], eff=89.2% (+18.9%)
  - UMa_NLOS: tau_90=0.81 мкс, L_g=[8,12], eff=79.2% (+8.9%)
  - RMa_NLOS: tau_90=0.08 мкс, L_g=[8,5], eff=90.9% (+20.6%)

### FRFT-SIC (из положения 3)
- N_fine=91, SIC_threshold_k=3.0, max_paths_sic=6
- residual_stop_dB=-20, N_refine_passes=6, prune_ratio=0.08
- LMMSE: truncated-SVD с floor (alpha=1e-3)

## Статус
Положение 1 завершено. Положение 2 (канал) — в работе.
QuaDRiGa подключена и работает для генерации каналов 3GPP 38.901.
