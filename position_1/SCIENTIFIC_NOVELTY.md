# Научная новизна — АСПА

## Дата: 2026-04-15

---

## Формулировка научной новизны для диссертации

### Основная новизна

**Адаптивный метод формирования кадра OTFS системы с оценкой канала FRFT-SIC,
валидированный на каналах QuaDRiGa (3GPP 38.901) для V2X сценариев 5.9 GHz.**

---

## 1. Научная новизна (что нового в науке)

### 1.1. Аналитический метод расчёта adaptive guard-зоны

**Что известно:** Все существующие работы (Raviteja, Hadnet) используют **фиксированную**
guard-зону, выбранную эмпирически. Reddy et al. (2022) упомянули, что "guard pilot size
depends on channel's delay spread" — но без аналитической формулы. Deng et al. (2025)
предложили динамическую адаптацию для LEO satellite — но это другой канал (не наземный V2X).

**Что предлагается:** Аналитическая формула расчёта guard-зоны на основе:
- Реального delay spread, извлечённого из каналов QuaDRiGa (median tau_90% по 100 RX)
- Максимального Doppler сдвига из скорости транспортного средства
- Требуемого уровня подавления sidelobes ядра Дирихле

```
L_guard_dopp(v, SNR)  = ceil(ν̃_spread(v)) + N_sidelobe(SNR)
L_guard_delay(scenario) = ceil(τ̃_90% / Δτ) + M_sidelobe
```

**Результат:** Spectral efficiency +8.9%...+20.6% при сохранении BER performance
для всех трёх 3GPP сценариев (UMi/UMa/RMa NLOS).

**Доказательство новизны:**
- [x] Найдено 41 статья (2021-2026) — ни одна не предлагает аналитический метод
  для наземных V2X с QuaDRiGa-based delay spread
- [x] Reddy et al. (#33) — общая идея, без формул и валидации
- [x] Deng et al. (#20) — LEO satellite, не наземный V2X
- [x] Wu et al. (#19) — "buffer band replacement", другой подход

### 1.2. Применение FRFT для оценки канала OTFS

**Что известно:** Основные методы оценки канала OTFS:
- SBL (Sparse Bayesian Learning) — высокая точность, но O(N³) сложность
- Prony — аналитический, но чувствителен к шуму
- Message passing — требует априорного знания числа путей
- Deep learning — требует обучения, неинтерпретируем

**Что предлагается:** **Fractional Fourier Transform + Successive Interference Cancellation**
- FRFT как обобщение FFT с параметром угла вращения α
- Позволяет напрямую оценивать fractional delay/Doppler без oversampling
- SIC — последовательное вычитание оценённых путей для улучшения точности
- LMMSE с truncated-SVD floor для стабилизации при низком SNR

**Доказательство новизны:**
- [x] В 41 найденной статье (2021-2026) FRFT не применялся для OTFS CE
- [x] Все методы используют DFT/FFT, SBL, или neural networks
- [x] FRFT позволяет работать с fractional parameters на уровне сигнала

### 1.3. QuaDRiGa-based валидация OTFS CE на 5.9 GHz V2X

**Что известно:** Большинство работ используют:
- Стохастические каналы (Rayleigh, Rician)
- Упрощённые 3GPP модели (TDL, CDL) без spatial consistency
- V2X-специфичные каналы — редко, и только для throughput анализа

**Что предлагается:** Полная валидация на **QuaDRiGa v2.8.1** (3GPP 38.901):
- Три сценария: UMi NLOS (10m BS), UMa NLOS (25m BS), RMa NLOS (35m BS)
- Извлечение реальных параметров канала из сгенерированных PDP
- Median delay spread (не worst-case): UMi=0.20 мкс, UMa=0.81 мкс, RMa=0.08 мкс
- Частота 5.9 GHz — стандартная для V2X (DSRC band)

**Доказательство новизны:**
- [x] Zheng et al. (#13) — 3GPP V2X, но GAMP-SBL, не FRFT, не 5.9 GHz
- [x] Chatzoulis et al. (#37) — 5.9 GHz, но coding schemes, не CE
- [x] Radovic (#38) — mmWave OTFS + 3GPP, но throughput, не CE
- [x] Первая работа с QuaDRiGa-based извлечением delay spread для adaptive guard

---

## 2. Практическая новизна (что нового в применении)

### 2.1. Spectral efficiency improvement

| Метрика | Fixed guard | Adaptive guard | Улучшение |
|---|---|---|---|
| UMi NLOS (v=80) | 70.3% | 89.2% | +18.9% |
| UMa NLOS (v=80) | 70.3% | 79.2% | +8.9% |
| RMa NLOS (v=80) | 70.3% | 90.9% | +20.6% |

### 2.2. Unified framework

Единый framework, объединяющий:
1. Adaptive frame design (положение 1)
2. QuaDRiGa channel modeling (положение 2)
3. FRFT-SIC channel estimation (положение 3)

---

## 3. Сравнение с ближайшими работами

| Работа | Метод | Guard | Channel | CE | Novelty gap |
|---|---|---|---|---|---|
| Raviteja et al. | Embedded pilot | Fixed | Stochastic | LS | Нет адаптивности |
| Reddy et al. (2022) | Reduced guard | Heuristic | — | — | Нет формул |
| Deng et al. (2025) | Dynamic guard | Adaptive | LEO satellite | — | Не V2X |
| Wu et al. (2025) | Buffer band | Replaced | — | Joint | Другой подход |
| Zheng et al. (2023) | GAMP-SBL | Fixed | 3GPP V2X | SBL | Не FRFT |
| **Наша работа** | **Adaptive + FRFT-SIC** | **Analytical** | **QuaDRiGa 3GPP** | **FRFT** | **Все 3 компонента** |

---

## 4. Потенциальные публикации

### 4.1. IEEE Communications Letters (4 страницы)
**Тема:** "Adaptive Guard Zone Design for OTFS Systems with FRFT-SIC Channel Estimation"
- Аналитическая формула guard-зоны
- BER vs SNR результаты
- Spectral efficiency comparison

### 4.2. IEEE VTC / GLOBECOM (6 страниц)
**Тема:** "QuaDRiGa-Based Validation of Adaptive OTFS Frame Design for V2X at 5.9 GHz"
- Полная валидация на 3 сценариях
- Сравнение adaptive vs fixed vs reduced guard
- QuaDRiGa-based delay spread extraction

### 4.3. IEEE TWC (полная статья, 12+ страниц)
**Тема:** "Joint Adaptive Frame Design and FRFT-SIC Channel Estimation for OTFS V2X Systems"
- Joint optimization frame design + CE
- Полный BER/MSE анализ
- Spectral efficiency model
- QuaDRiGa validation

---

## 5. Источники (Google Scholar)

Все статьи найдены через https://scholar.google.com по запросам:
- "OTFS frame structure pilot design guard band"
- "OTFS adaptive guard delay spread spectral efficiency"
- "OTFS fractional Fourier transform channel estimation"
- "OTFS 3GPP channel model V2X vehicular 5.9GHz"

Полный список — в `documentation/LITERATURE_REVIEW.md` (41 статья, 2021-2026).
