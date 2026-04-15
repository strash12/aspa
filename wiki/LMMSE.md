# LMMSE

## Описание
Linear Minimum Mean Square Error эквалайзер с truncated-SVD и noise floor. Используется после оценки канала FRFT-SIC для равнизации OTFS сигнала.

## Связи
- [[FRFT-SIC]] — оценка канала, вход для LMMSE
- [[Положение 3]] — реализация LMMSE

## Теги
#equalizer #LMMSE #SVD

## Содержание

### Truncated-SVD с floor
```
α_floor = 1e-3  (n0_eff = max(n0, 1e-3 * σ_max²))
α_tol = 1e-10   (truncation tolerance)
```

### Почему floor нужен
Без floor: estimation errors усиливаются при высоком SNR → BER stuck at ~1e-2
С floor: BER продолжает падать до ~2e-4 при SNR=30 dB

Для TRUE канала: все 3 варианта (direct/SVD-no-floor/SVD-floor) идентичны — floor не мешает когда канал точный.

## Источники
- `position_3/PROJECT_CONTEXT.md`
