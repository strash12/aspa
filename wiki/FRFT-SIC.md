# FRFT-SIC

## Описание
Алгоритм оценки канала OTFS через Fractional Fourier Transform + Successive Interference Cancellation. Оценивает параметры путей (задержка, Допплер, усиление) из DD-отклика канала.

## Связи
- [[OTFS]] — система, для которой оценивается канал
- [[LMMSE]] — эквалайзер, использующий результаты FRFT-SIC
- [[Положение 3]] — полная реализация алгоритма
- [[Fractional Doppler]] — проблема, которую решает FRFT-SIC

## Теги
#channel_estimation #FRFT #SIC #algorithm

## Содержание

### 4-этапный pipeline
1. **Initial SIC**: greedy peak search в Hdd → fine 2D FRFT (91×91 grid) → parabolic interpolation → LS gain → residual. До 6 итераций.
2. **Joint LS re-estimation**: A\r для всех найденных путей одновременно (корректирует bias от greedy extraction)
3. **Pruning**: удаление путей с |gain| < 8% от max. Повторный joint LS.
4. **Multi-pass refinement**: 6 проходов, каждый:
   - Leave-one-out residual для каждого пути
   - Narrow fine search (31×31) с adaptive radius [0.4, 0.4, 0.2, 0.2, 0.1, 0.1]
   - Parabolic interpolation
   - Joint LS после каждого прохода
   - Final pruning

### Параметры
```
N_fine = 91
SIC_threshold_k = 3.0
max_paths_sic = 6
residual_stop_dB = -20
N_refine_passes = 6
prune_ratio = 0.08
```

### Результаты
- Ablation: V0→V4 улучшение ×10.8
- BER при SNR=30 dB: TRUE=1.3e-5, FRFT=1.45e-4

## Источники
- `position_3/PROJECT_CONTEXT.md`
