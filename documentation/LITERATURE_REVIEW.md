# Обзор литературы — OTFS с учётом fractional delay/Doppler

## Дата: 2026-04-15

---

## Часть 1. Ключевые статьи (2025-2026)

### 1.1. Оценка канала с fractional delay/Doppler

| # | Статья | Метод | Ключевая идея |
|---|---|---|---|
| 1 | **Jitsumatsu & Sun, 2025** — "Two-Stage Prony-Based Estimation of Fractional Delay and Doppler Shifts in OTFS" | Prony + DFT | Последовательный подход: сначала Doppler через Prony, потом delay через DFT. Обходит проблему дробной сетки без итеративного поиска |
| 2 | **Wang et al., 2025** — "Cyclic Shift Embedded Pilot for MU-MIMO-OTFS with fractional delay and Doppler" | Subspace + compressed sensing | Циклически сдвинутые пилоты для разделения пользователей + subspace decomposition для off-grid параметров |
| 3 | **Marchese & Savazzi, 2026** — "Cross-Pilot Superposition for Fractional Parameter Estimation in DoA-Aided OTFS" | Angular separation + correlation | Угловое разделение путей (DoA) + усреднение по осям для выделения fractional параметров |
| 4 | **Qi et al., 2025** — "Sparse Bayesian Learning with Adaptive Threshold" | SBL + adaptive threshold | Inverse-free SBL с адаптивным порогом для подавления шума при fractional Doppler |
| 5 | **Cao et al., 2026** — "Nonparametric Variational Bayesian Learning" | Stick-breaking process | Автоматическое определение числа путей без априорного знания |
| 6 | **Gehlot et al., 2026** — "Gaussian Mixture Model Based Bayesian Learning" | GMM + SBL | Иерархические GMM-приоры для моделирования сложной статистики замираний |
| 7 | **Hashimoto et al., 2021** — "Channel estimation and equalization for CP-OFDM-based OTFS in fractional Doppler channels" | Symplectic FFT | Symplectic finite Fourier transform для компенсации fractional Doppler |
| 8 | **Sheng & Wu, 2023** — "Time-frequency domain channel estimation for OTFS systems" | TF-domain CE | BER почти достигает идеального CSI при TF-оценке |
| 9 | **Mattu & Chockalingam, 2024** — "Learning in time-frequency domain for fractional delay-Doppler channel estimation in OTFS" | ISF-based learning | Inverse symplectic finite Fourier transform для fractional DD-канала |
| 10 | **Liu et al., 2021** — "Message passing-based structured sparse signal recovery for estimation of OTFS channels with fractional Doppler shifts" | Message passing + SFSF | Structured sparse recovery через dimensional inverse symplectic FFT |
| 11 | **Khan & Mohammed, 2021** — "Low complexity channel estimation for OTFS modulation with fractional delay and Doppler" | Pilot-only frame | Упрощённая структура кадра только с пилотами для low-complexity CE |
| 12 | **Priya et al., 2024** — "OTFS channel estimation and detection for channels with very large delay spread" | Adaptive threshold | Adaptive thresholds для aliased delay estimation при большом delay spread |
| 13 | **Zheng et al., 2023** — "Gamp-based low-complexity sparse bayesian learning channel estimation for OTFS systems in V2X scenarios" | GAMP + SBL | 3GPP V2X channel model + discrete-time OTFS formulation |

### 1.2. Дизайн пилотов и кадра

| # | Статья | Метод | Ключевая идея |
|---|---|---|---|
| 14 | **Wang & Petropulu, 2025** — "Low Overhead Scalable TF Pilots for MIMO-OTFS" | Virtual array + guard regions | Пилоты в TF-области с guard-зонами → virtual array для sparse recovery |
| 15 | **Zedka et al., 2026** — "Unique Word Channel Estimation for Oversampled OTFS" | Oversampling + time-domain pilots | Перенос пилотов в oversampled time domain — предотвращает energy leakage от pulse shaping |
| 16 | **Chen & Su, 2026** — "Low-Complexity Pilot-Aided Doppler Ambiguity Estimation" | Pairwise phase + ML | Разрешение Doppler aliasing через попарные фазовые сравнения |
| 17 | **Wang et al., 2021** — "Pilot design and optimization for OTFS modulation" | DD-grid config | N=32, M=128 оптимизация DD-сетки для мобильности |
| 18 | **Karimian-Sichani et al., 2025** — "2D pilot signal design for OTFS-ISAC systems" | Guard band + zero pilots | 2D пилоты с guard band для dual-purpose sensing/communication |
| 19 | **Wu et al., 2025** — "Superimposed Pilot-Data Co-Design Framework with Buffer Band in OTFS System" | Buffer band replacement | Замена conventional guard bands на active data — joint pilot-data optimization |
| 20 | **Deng et al., 2025** — "Adaptive OTFS Frame Design and Resource Allocation for High-Mobility LEO Satellite Communications" | Dynamic pilot guard | Динамическая адаптация pilot guard bands для LEO satellite links |

### 1.3. Pulse shaping и waveform design

| # | Статья | Метод | Ключевая идея |
|---|---|---|---|
| 21 | **Jesbin & Chockalingam, 2025** — "DD Pulse Shaping in Zak-OTFS Using Hermite Basis" | Hermite pulse optimization | Оптимизация коэффициентов Hermite-базиса для минимизации ISI при fractional shifts |
| 22 | **Zhang et al., 2026** — "Pulse Shaping Filter Design for Zak-OTFS" | Specialized waveforms | Синтез вейвлетов для минимизации sidelobe spreading |
| 23 | **Sanoopkumar et al., 2025** — "Time Frequency Localized Pulse" | Localized pulse design | Подавление интерференции от fractional delays и timing offsets |
| 24 | **Sun & Jitsumatsu, 2025** — "OTFS Radar with Window Function" | Generalized window + autocorrelation interpolation | Гибкое окно + автокорреляционная интерполяция для radar |
| 25 | **Khammammetti et al., 2022** — "Spectral efficiency of OTFS based orthogonal multiple access with rectangular pulses" | No guard bands | OTFS-OMA без guard bands в resource assignment |
| 26 | **Hossain & Ryu, 2021** — "Advanced OTFS communication system with compact spectrum and power efficiency improvement" | Waveform shaping | Waveform shaping для подавления OOB emissions |
| 27 | **Xu et al., 2023** — "Optical OTFS is capable of improving the bandwidth-, power-and energy-efficiency of optical OFDM" | Single prefix | Consolidation overhead в single prefix per frame |
| 28 | **Tusha & Arslan, 2023** — "Low complex inter-Doppler interference mitigation for OTFS systems via global receiver windowing" | Unified prefix | Unified extension для лучшей spectral efficiency |

### 1.4. Deep learning подходы

| # | Статья | Метод | Ключевая идея |
|---|---|---|---|
| 29 | **Zhang et al., 2025** — "DL-based OTFS CE with Plug-and-Play" | Optimization + lightweight NN | Адаптивное отслеживание вариаций канала, компенсация fractional Doppler spreading |
| 30 | **Lei et al., 2026** — "Superimposed-Pilot OTFS Under Fractional Doppler: Modular E2E Learning" | U-Net + modular framework | Joint channel estimation + symbol detection через U-Net |
| 31 | **Men et al., 2026** — "DL-Based Coarse-to-Fine Frame Synchronization" | Hierarchical ResNet | Классификация timing offsets через периодические пилоты |
| 32 | **Zhou et al., 2022** — "Learning to equalize OTFS" | NN equalizer | Guard interval free neural network equalizer |

### 1.5. Spectral efficiency и guard band optimization

| # | Статья | Метод | Ключевая идея |
|---|---|---|---|
| 33 | **Reddy et al., 2022** — "Spectral efficient modem design with OTFS modulation for vehicular-IoT system" | Reduced guard pilot | Уменьшение guard pilot в ZP-OTFS; guard size зависит от channel delay spread |
| 34 | **Wang et al., 2024** — "Reduced Guard Interval Orthogonal Frequency Division Multiplexing: A Soft Trade-Off Solution Toward Spectral Efficiency" | Dynamic guard shortening | Duration of delay spread rests with the transmission channel |
| 35 | **Yuan et al., 2023** — "New delay Doppler communication paradigm in 6G era: A survey of orthogonal time frequency space (OTFS)" | Survey | Linear scaling of spectral efficiency, adaptive schemes без traditional spacing |
| 36 | **Deng et al., 2025** — "A unifying view of OTFS and its many variants" | Survey | Discrete impulse pilots + null guard symbols вокруг пилотов |

### 1.6. 3GPP каналы и V2X сценарии

| # | Статья | Метод | Ключевая идея |
|---|---|---|---|
| 37 | **Chatzoulis et al., 2023** — "5G V2X performance comparison for different channel coding schemes and propagation models" | 3GPP V2X models | 5.9 GHz band + 3GPP 4G-LTE/5G-NR V2X channel models |
| 38 | **Radovic, 2026** — "Vehicular Connectivity Based on Millimeter Wave Orthogonal Time Frequency Space Modulation" | 3GPP vehicular | OTFS + 3GPP vehicular channel model + 5.9 GHz legacy band |
| 39 | **Rodriguez et al., 2025** — "6G-enabled vehicle-to-everything communications: Current research trends and open challenges" | Survey | 5.9 GHz band + Superimposed Training-OTFS (ST-OTFS) |

### 1.7. Обзоры

| # | Статья | Охват |
|---|---|---|
| 40 | **Aslandogan et al., 2025** — "Comprehensive Survey of CE for OTFS" | Bayesian, sparse recovery, message passing, NN — все подходы |
| 41 | **Ozden et al., 2025** — "OTFS Index Modulation Survey" | Index modulation + estimation при imperfect CSI |

---

## Часть 2. Проблема fractional delay/Doppler — технический обзор

### 2.1. Суть проблемы

При прямоугольном импульсе (bi-orthogonal pulse shaping) отклик канала в DD-области
описывается **2D ядром Дирихле**:

```
K(τ, ν) = (1/MN) · sin(π(τ-τ₀)) / sin(π(τ-τ₀)/M) · sin(π(ν-ν₀)) / sin(π(ν-ν₀)/N) · e^(jφ)
```

Когда параметры пути (τ₀, ν₀) — **целые** (находятся точно на узлах сетки):
- Энергия сосредоточена в одном бине
- Боковые лепестки малы

Когда параметры **дробные** (off-grid):
- Энергия "размазывается" по нескольким бинам
- Боковые лепестки ядра Дирихле создают **интерференцию**
- Спreading пропорционален расстоянию до ближайшего узла сетки

### 2.2. Влияние на guard-зону

Текущий подход (положение 3):
```
L_guard_delay = 14, L_guard_dopp = 10
```

Эти значения выбраны эмпирически. Проблема:
- При df=15 кГц и v=120 км/ч → ν̃ ≈ 1.66 bins
- Боковые лепестки Dirichlet убывают как 1/x — **медленно**
- Guard-зона "съедает" ~30% DD-сетки (608 из 2048 bins)
- При увеличении скорости guard-зона должна расти

### 2.3. Существующие подходы к fractional проблеме

| Подход | Плюсы | Минусы |
|---|---|---|
| **Увеличение guard-зоны** (Raviteja) | Простота | Потеря спектральной эффективности |
| **SBL off-grid** (Wei, Zhao) | Точность | Высокая сложность O(N³) |
| **FRFT fine search** (наш, положение 3) | Баланс точность/сложность | Зависит от начального приближения |
| **Prony-based** (Jitsumatsu) | Не требует поиска | Чувствителен к шуму |
| **Oversampling** (Zedka) | Предотвращает leakage | Увеличивает размерность |
| **Pulse shaping** (Hermite, Zak-OTFS) | Уменьшает sidelobes | Усложняет TX/RX |

---

## Часть 3. Сохранённые статьи

Следующие статьи рекомендуется сохранить в папку `документация/` (ссылки для скачивания):

| Файл | Ссылка |
|---|---|
| `arxiv_otfs_survey_2025.md` | https://arxiv.org/search/?query=OTFS+channel+estimation (Aslandogan et al.) |
| `arxiv_prony_fractional_2025.md` | Jitsumatsu & Sun — Two-Stage Prony-Based Estimation |
| `arxiv_cyclic_pilot_mimo_2025.md` | Wang et al. — Cyclic Shift Embedded Pilot |
| `arxiv_cross_pilot_superposition_2026.md` | Marchese & Savazzi — Cross-Pilot Superposition |
| `arxiv_hermite_pulse_2025.md` | Jesbin & Chockalingam — DD Pulse Shaping in Zak-OTFS |
| `arxiv_sbl_adaptive_2025.md` | Qi et al. — SBL with Adaptive Threshold |
| `arxiv_unique_word_oversampled_2026.md` | Zedka et al. — Unique Word for Oversampled OTFS |
| `arxiv_dl_plug_and_play_2025.md` | Zhang et al. — DL-based CE with Plug-and-Play |
| `arxiv_superimposed_unet_2026.md` | Lei et al. — Superimposed-Pilot U-Net |
| `arxiv_nonparametric_variational_2026.md` | Cao et al. — Nonparametric Variational Bayesian |

---

## Часть 4. Что НЕ решено в литературе (окна для научной новизны)

### 4.1. Адаптивная guard-зона на основе реального delay spread (частично решено)

**Проблема:** Большинство работ используют фиксированную guard-зону.
Reddy et al. (2022, #33) предложили уменьшение guard pilot, где "guard pilot size
depends on the channel's delay spread" — но без аналитической формулы.
Deng et al. (2025, #20) — "dynamically adjusting the pilot guard bands" для LEO satellite,
но не для наземных V2X сценариев.

**Наш подход:** Аналитический расчёт guard-зоны из **реального delay spread**,
извлечённого из каналов QuaDRiGa (3GPP 38.901), а не из табличных worst-case значений.
```
L_guard_dopp  = ceil(ν̃_spread(v)) + N_sidelobe(SNR)
L_guard_delay = ceil(τ̃_90% / Δτ) + M_sidelobe
```
где τ̃_90% извлекается из реальных каналов (median по 100 RX QuaDRiGa).

**Новизна:**
- Reddy et al. (#33) — общая идея, без формул
- Deng et al. (#20) — для LEO satellite, другой канал
- **Мы:** первый аналитический метод для наземных 3GPP сценариев (UMi/UMa/RMa)
  с валидацией через QuaDRiGa, показывающий +8.9%...+20.6% spectral efficiency

### 4.2. FRFT-SIC для оценки канала (не решено)

**Проблема:** Существующие методы:
- SBL (Qi #4, Cao #5, Zheng #13) — высокая сложность O(N³)
- Prony (Jitsumatsu #1) — чувствителен к шуму
- Message passing (Liu #10) — требует априорного знания числа путей
- Deep learning (Zhang #29, Lei #30) — требует обучения, неинтерпретируемы

**Наш подход:** **Fractional Fourier Transform + Successive Interference Cancellation**
- FRFT как обобщение FFT с параметром угла вращения α
- SIC — последовательное вычитание оценённых путей
- LMMSE с truncated-SVD floor для стабилизации

**Новизна:** FRFT не применялся для OTFS channel estimation в найденной литературе.
Все методы используют стандартный DFT/FFT или SBL. FRFT позволяет напрямую
оценивать fractional delay/Doppler без oversampling или grid refinement.

### 4.3. Joint frame design + channel estimation (не решено)

**Проблема:** Frame design (пилот + guard) и channel estimation рассматриваются
раздельно. Но оптимальная guard-зона зависит от алгоритма оценки.

**Идея:** **Joint optimization** — итеративный процесс:
1. Начальная оценка канала → оценка fractional параметров
2. Оптимизация guard-зоны под конкретный канал
3. Переоценка канала с новой guard-зоной
4. Repeat until convergence

**Новизна:** Нет работ с обратной связью между оценкой канала и дизайном кадра.
Wu et al. (#19) — "buffer band replacement" но без обратной связи с CE алгоритмом.

### 4.4. QuaDRiGa-based валидация для OTFS (не решено)

**Проблема:** Большинство работ используют стохастические каналы (Rayleigh, Rician)
или упрощённые 3GPP модели (TDL, CDL). V2X-специфичные каналы:
- Zheng et al. (#13) — 3GPP V2X, но GAMP-SBL, не FRFT
- Chatzoulis et al. (#37) — 5.9 GHz, но сравнение coding schemes, не CE
- Radovic (#38) — mmWave OTFS + 3GPP, но 2026, фокус на throughput

**Наш подход:** Полная валидация на **QuaDRiGa v2.8.1** (3GPP 38.901)
с извлечением реальных параметров канала (delay spread, Doppler spread)
из сгенерированных импульсных характеристик.

**Новизна:** Первая работа, которая:
1. Использует QuaDRiGa для OTFS CE валидации на 5.9 GHz
2. Извлекает median delay spread из реальных каналов (не табличные значения)
3. Сравнивает 3 сценария (UMi/UMa/RMa NLOS) с едиными параметрами OTFS

### 4.5. Pulse shaping для уменьшения sidelobes (частично решено)

**Проблема:** Zak-OTFS с Hermite pulse (статьи 21, 23) решает sidelobe проблему,
но требует полного redesign TX/RX цепочки.

**Идея:** **Hybrid pulse shaping** — стандартный rectangular pulse на TX,
но **receive-side windowing** с оптимизированным окном, которое минимизирует
sidelobes Dirichlet kernel без изменения TX.

**Новизна:** Существующие работы (Sanoopkumar, Jesbin) меняют TX.
Приёмное окно с аналитически оптимизированными коэффициентами для OTFS — менее изучено.

### 4.6. Spectral efficiency analysis с fractional (частично решено)

**Проблема:** BER vs SNR показывает качество, но **spectral efficiency** (бит/с/Гц)
с учётом guard-зоны, pilot power, fractional spreading — не анализировалась
систематически. Yuan et al. (#35) — survey, упоминает "linear scaling of spectral
efficiency" но без аналитической модели.

**Наш подход:** Аналитическая модель spectral efficiency:
```
η = (N_data · log2(M_mod)) / (M·N)
```
где N_data — функция от адаптивной guard-зоны, зависящей от сценария и SNR.

**Результат:** Показано, что adaptive guard даёт +8.9%...+20.6% spectral efficiency
при сохранении BER performance (QuaDRiGa-based валидация).

### 4.7. Multi-frame tracking (не решено)

**Проблема:** Все алгоритмы оценивают канал для одного кадра.
Но в реальности канал меняется медленно — можно использовать информацию
из предыдущих кадров.

**Идея:** **Kalman filter** или **exponential smoothing** для трекинга
параметров путей (τ, ν, h) между кадрами.

**Новизна:** Практически нет работ по multi-frame tracking в OTFS.

---

## Часть 5. Рекомендации для научной новизны

### Наиболее перспективные направления (по убыванию):

1. **Joint frame design + channel estimation** (4.3)
   - Наибольшая новизна — никто не связывал дизайн кадра с оценкой
   - Можно использовать результаты положения 3 как baseline
   - Публикация: IEEE TWC / JSAC

2. **FRFT + Prony hybrid** (4.4)
   - Конкретный алгоритм, легко реализовать на базе существующего кода
   - Уменьшение сложности vs pure grid search
   - Публикация: IEEE VTC / GLOBECOM

3. **Spectral efficiency analysis** (4.5)
   - Аналитический результат — не требует новых симуляций
   - Можно добавить к существующей статье как Section V-H
   - Публикация: IEEE Communications Letters

4. **Adaptive guard zone** (4.1)
   - Простая идея, но требует обоснования
   - Может быть частью joint optimization (4.3)
