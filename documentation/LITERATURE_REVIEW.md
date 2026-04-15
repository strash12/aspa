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

### 1.2. Дизайн пилотов и кадра

| # | Статья | Метод | Ключевая идея |
|---|---|---|---|
| 7 | **Wang & Petropulu, 2025** — "Low Overhead Scalable TF Pilots for MIMO-OTFS" | Virtual array + guard regions | Пилоты в TF-области с guard-зонами → virtual array для sparse recovery |
| 8 | **Zedka et al., 2026** — "Unique Word Channel Estimation for Oversampled OTFS" | Oversampling + time-domain pilots | Перенос пилотов в oversampled time domain — предотвращает energy leakage от pulse shaping |
| 9 | **Chen & Su, 2026** — "Low-Complexity Pilot-Aided Doppler Ambiguity Estimation" | Pairwise phase + ML | Разрешение Doppler aliasing через попарные фазовые сравнения |

### 1.3. Pulse shaping и waveform design

| # | Статья | Метод | Ключевая идея |
|---|---|---|---|
| 10 | **Jesbin & Chockalingam, 2025** — "DD Pulse Shaping in Zak-OTFS Using Hermite Basis" | Hermite pulse optimization | Оптимизация коэффициентов Hermite-базиса для минимизации ISI при fractional shifts |
| 11 | **Zhang et al., 2026** — "Pulse Shaping Filter Design for Zak-OTFS" | Specialized waveforms | Синтез вейвлетов для минимизации sidelobe spreading |
| 12 | **Sanoopkumar et al., 2025** — "Time Frequency Localized Pulse" | Localized pulse design | Подавление интерференции от fractional delays и timing offsets |
| 13 | **Sun & Jitsumatsu, 2025** — "OTFS Radar with Window Function" | Generalized window + autocorrelation interpolation | Гибкое окно + автокорреляционная интерполяция для radar |

### 1.4. Deep learning подходы

| # | Статья | Метод | Ключевая идея |
|---|---|---|---|
| 14 | **Zhang et al., 2025** — "DL-based OTFS CE with Plug-and-Play" | Optimization + lightweight NN | Адаптивное отслеживание вариаций канала, компенсация fractional Doppler spreading |
| 15 | **Lei et al., 2026** — "Superimposed-Pilot OTFS Under Fractional Doppler: Modular E2E Learning" | U-Net + modular framework | Joint channel estimation + symbol detection через U-Net |
| 16 | **Men et al., 2026** — "DL-Based Coarse-to-Fine Frame Synchronization" | Hierarchical ResNet | Классификация timing offsets через периодические пилоты |

### 1.5. Обзоры

| # | Статья | Охват |
|---|---|---|
| 17 | **Aslandogan et al., 2025** — "Comprehensive Survey of CE for OTFS" | Bayesian, sparse recovery, message passing, NN — все подходы |
| 18 | **Ozden et al., 2025** — "OTFS Index Modulation Survey" | Index modulation + estimation при imperfect CSI |

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

### 4.1. Адаптивная guard-зона (не решено)

**Проблема:** Все работы используют фиксированную guard-зону, но fractional spreading
зависит от скорости и задержки.

**Идея:** Адаптивная guard-зона, вычисляемая из оценки максимального Doppler:
```
L_guard_dopp = ceil(|ν̃_max| + margin)
L_guard_delay = ceil(|τ̃_max| + margin)
```
где ν̃_max оценивается из coarse Doppler spectrum до полной оценки канала.

**Новизна:** Нет работ, которые бы динамически оптимизировали guard-зону
на основе предварительной оценки канала. Все используют фиксированные значения.

### 4.2. Pulse shaping для уменьшения sidelobes (частично решено)

**Проблема:** Zak-OTFS с Hermite pulse (статьи 10, 12) решает sidelobe проблему,
но требует полного redesign TX/RX цепочки.

**Идея:** **Hybrid pulse shaping** — стандартный rectangular pulse на TX,
но **receive-side windowing** с оптимизированным окном, которое минимизирует
sidelobes Dirichlet kernel без изменения TX.

**Новизна:** Существующие работы (Sanoopkumar, Jesbin) меняют TX.
Приёмное окно с аналитически оптимизированными коэффициентами для OTFS — менее изучено.

### 4.3. Joint frame design + channel estimation (не решено)

**Проблема:** Frame design (пилот + guard) и channel estimation рассматриваются
раздельно. Но оптимальная guard-зона зависит от алгоритма оценки.

**Идея:** **Joint optimization** — итеративный процесс:
1. Начальная оценка канала → оценка fractional параметров
2. Оптимизация guard-зоны под конкретный канал
3. Переоценка канала с новой guard-зоной
4. Repeat until convergence

**Новизна:** Нет работ с обратной связью между оценкой канала и дизайном кадра.

### 4.4. FRFT + Prony hybrid (не решено)

**Проблема:** FRFT-SIC (положение 3) — greedy поиск на сетке. Prony (Jitsumatsu) —
аналитический, но чувствителен к шуму.

**Идея:** **Prony для coarse оценки → FRFT fine search** — комбинация:
- Prony даёт начальное приближение без поиска
- FRFT fine search уточняет с учётом шума
- Joint LS устраняет bias

**Новизна:** Никто не комбинировал Prony + FRFT для OTFS.

### 4.5. Spectral efficiency analysis с fractional (не решено)

**Проблема:** BER vs SNR показывает качество, но **spectral efficiency** (бит/с/Гц)
с учётом guard-зоны, pilot power, fractional spreading — не анализировалась
систематически.

**Идея:** Аналитическая модель spectral efficiency:
```
η = (N_data · log2(M_mod)) / (N_total · (1 + α_guard + α_pilot))
```
где α_guard и α_pilot — функции от fractional параметров.

**Новизна:** Нет работ, которые бы связывали fractional spreading напрямую
с потерей spectral efficiency.

### 4.6. Multi-frame tracking (не решено)

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
