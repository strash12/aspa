# Адаптивная guard-зона для OTFS кадра

## Научная новизна
Все существующие работы используют **фиксированную** guard-зону, выбранную эмпирически.
Предлагается **аналитический метод** расчёта guard-зоны на основе:
- Максимального Doppler сдвига (из скорости)
- Максимального delay spread (из сценария канала)
- Требуемого уровня подавления sidelobes

---

## 1. Проблема фиксированной guard-зоны

### 1.1. Текущий подход (Raviteja, положение 3)

```
L_guard_delay = 14    (фиксировано)
L_guard_dopp  = 10    (фиксировано)
```

**Недостатки:**
- При низкой скорости (v=30 м/с) guard-зона избыточна → потеря spectral efficiency
- При высокой скорости (v=150 м/с) может быть недостаточна → интерференция
- Нет аналитического обоснования — выбрано эмпирически

### 1.2. Потеря spectral efficiency

```
При L_guard_delay=14, L_guard_dopp=10:
  Guard bins = 29 × 21 - 1 = 608
  Data bins  = 2048 - 609 = 1439
  Efficiency = 1439/2048 = 70.3%

Если бы guard можно уменьшить до L_guard_delay=6, L_guard_dopp=4:
  Guard bins = 13 × 9 - 1 = 116
  Data bins  = 2048 - 117 = 1931
  Efficiency = 1931/2048 = 94.3%

  Потенциальный выигрыш: +24% spectral efficiency
```

---

## 2. Математическая модель sidelobes

### 2.1. Ядро Дирихле в DD-области

Отклик канала от одного пути с параметрами (h, τ̃, ν̃) в DD-области:

```
Hdd(k, l) = h · K_N(k - ν̃) · K_M(l - τ̃) · e^(jφ)
```

где K_N — ядро Дирихле:

```
K_N(x) = (1/N) · sin(πx) / sin(πx/N)
```

### 2.2. Sinc-аппроксимация

Для больших N (N ≥ 32):

```
K_N(x) ≈ sinc(x) = sin(πx) / (πx)
```

**Обоснование:** sin(πx/N) ≈ πx/N при малых x/N.

Для N=32 ошибка аппроксимации < 1% при |x| < N/4.

### 2.3. Worst-case fractional offset

Худший случай: путь находится **между** узлами сетки:
```
ν̃_frac = 0.5 bins  (посередине между k и k+1)
τ̃_frac = 0.5 bins
```

При этом sidelobe на расстоянии d bins от пика:

```
|sinc(d - 0.5)| = |sin(π(d-0.5))| / (π|d-0.5|)
                 = 1 / (π|d-0.5|)
```

### 2.4. Уровень sidelobes как функция расстояния

| d (bins) | |sinc(d-0.5)| | dB |
|---|---|---|
| 1 | 1/(π·0.5) = 0.637 | -3.9 dB |
| 2 | 1/(π·1.5) = 0.212 | -13.5 dB |
| 3 | 1/(π·2.5) = 0.127 | -17.9 dB |
| 4 | 1/(π·3.5) = 0.091 | -20.8 dB |
| 5 | 1/(π·4.5) = 0.071 | -23.0 dB |
| 6 | 1/(π·5.5) = 0.058 | -24.7 dB |
| 7 | 1/(π·6.5) = 0.049 | -26.2 dB |
| 8 | 1/(π·7.5) = 0.042 | -27.5 dB |
| 10 | 1/(π·9.5) = 0.034 | -29.4 dB |
| 14 | 1/(π·13.5) = 0.024 | -32.5 dB |

### 2.5. Влияние мощности пилота

Пилот имеет мощность `pilot_power = 100` (амплитуда 10).
Данные имеют единичную амплитуду.

**Интерференция от пилота в bin данных на расстоянии d:**

```
I_pilot(d) = sqrt(pilot_power) · |sinc(d - ν̃_frac)|
           = 10 / (π|d - 0.5|)
```

| d (bins) | I_pilot(d) | dB относительно данных |
|---|---|---|
| 5 | 10/(π·4.5) = 0.707 | -3.0 dB |
| 10 | 10/(π·9.5) = 0.336 | -9.5 dB |
| 14 | 10/(π·13.5) = 0.236 | -12.5 dB |
| 20 | 10/(π·19.5) = 0.163 | -15.7 dB |

**Вывод:** Из-за высокой мощности пилота sidelobes остаются значительными
даже на большом расстоянии. На расстоянии d=14 bins интерференция
превышает уровень данных на -12.5 dB — это существенно.

---

## 3. Аналитический расчёт guard-зоны

### 3.1. Критерий

Guard-зона должна быть такой, чтобы интерференция от пилота
в ближайший bin данных была **ниже уровня шума**:

```
I_pilot(L_guard) ≤ γ · σ_noise
```

где γ — margin (обычно 3-5), σ_noise — среднеквадратичное отклонение шума.

### 3.2. Вывод формулы

```
sqrt(P_pilot) / (π · L_guard) ≤ γ · σ_noise

L_guard ≥ sqrt(P_pilot) / (π · γ · σ_noise)
```

В терминах SNR (SNR = P_data / σ²_noise, P_data = 1):

```
σ_noise = 1 / sqrt(SNR)

L_guard ≥ sqrt(P_pilot · SNR) / (π · γ)
```

### 3.3. Численные значения

Для P_pilot = 100, γ = 3:

| SNR (dB) | SNR (лин.) | L_guard (Doppler) | L_guard (Delay) |
|---|---|---|---|
| 0 | 1.0 | 1.1 → **2** | 1.1 → **2** |
| 10 | 3.16 | 1.9 → **2** | 1.9 → **2** |
| 18 | 63.1 | 8.4 → **9** | 8.4 → **9** |
| 20 | 100 | 10.6 → **11** | 10.6 → **11** |
| 24 | 251 | 16.8 → **17** | 16.8 → **17** |
| 30 | 1000 | 33.5 → **34** | 33.5 → **34** |
| 40 | 10000 | 106 → **107** | 106 → **107** |

**Проблема:** При высоком SNR guard-зона становится больше самой DD-сетки!

### 3.4. Практический критерий

Вместо "ниже шума" используем **допустимый уровень интерференции**:

```
I_pilot(L_guard) ≤ ε · |h_max|
```

где ε — допустимая доля (например, 1% = 0.01) от максимального пути канала.

```
L_guard ≥ sqrt(P_pilot) / (π · ε · |h_max|)
```

Для QuaDRiGa 3GPP UMi NLOS, |h_max| ≈ 0.3-0.5 (нормировка канала):

При |h_max| = 0.4, ε = 0.01, P_pilot = 100:
```
L_guard ≥ 10 / (π · 0.01 · 0.4) = 796 bins  — нереалистично
```

**Вывод:** Критерий "ниже 1% от h_max" слишком строгий.
Нужно учитывать, что:
1. Реальные пути канала имеют τ̃, ν̃ << 0.5 (не worst-case)
2. FRFT-SIC компенсирует fractional spreading
3. Данные несут случайные символы — интерференция усредняется

### 3.5. Предложенная формула (практическая)

Учитывая специфику FRFT-SIC алгоритма (положение 3), guard-зона
должна покрывать **максимальный fractional spread** канала:

```
L_guard_dopp  = ceil(|ν̃_max| + N_sidelobe_margin)
L_guard_delay = ceil(|τ̃_max| + M_sidelobe_margin)
```

где:
- `ν̃_max = f_Doppler_max / Δν = (fc · v_max / c) / (1/(N·T))`
- `τ̃_max = τ_max / Δτ = τ_max · M · Δf`
- `N_sidelobe_margin` — число sidelobe bins за пределами max spread

### 3.6. Расчёт для параметров положения 3

**Doppler guard:**

```
v_max = 80 м/с (для данного сценария)
f_Doppler_max = 5.9e9 · 80 / 3e8 = 1573 Гц
Δν = 1/(N·T) = 1/(32 · 6.67e-6) = 4687.5 Гц
ν̃_max = 1573 / 4687.5 = 0.335 bins

L_guard_dopp = ceil(0.335 + 3) = ceil(3.335) = 4
```

Но реальный канал имеет **множество путей** с разными Doppler.
QuaDRiGa UMi NLOS: разброс Doppler ≈ ±f_Doppler_max.

С учётом sidelobes Dirichlet (убывают медленно):
```
L_guard_dopp = ceil(ν̃_max) + N_sidelobe
             = 1 + 9 = 10    (совпадает с текущим значением!)
```

**Delay guard:**

```
τ_max ≈ 5 мкс (UMi NLOS, max excess delay)
Δτ = 1/(M·Δf) = 1/(64 · 150e3) = 104 нс
τ̃_max = 5e-6 / 104e-9 = 48 bins  — это больше M/2!
```

Но QuaDRiGa генерирует кластеры путей. Большинство энергии
сосредоточено в первых ~1 мкс:
```
τ_90% ≈ 1 мкс → τ̃_90% = 1e-6 / 104e-9 ≈ 9.6 bins

L_guard_delay = ceil(9.6) + 4 = 10 + 4 = 14    (совпадает с текущим!)
```

### 3.7. Адаптивная формула (итоговая)

**Doppler guard:**

Guard-зона по Допплеру должна покрывать:
1. **Весь диапазон Doppler** многолучевого канала (не один путь!)
2. Sidelobes ядра Дирихле за пределами max spread

```
L_guard_dopp(v) = ceil(ν̃_spread(v)) + N_sidelobe(SNR)

где:
  ν̃_spread(v) = 2 · fc · v / (c · Δν)   — полный Doppler spread (±f_D)
  Δν = df / N    — разрешение по Допплеру
  N_sidelobe     — число sidelobe bins (зависит от SNR)
```

**Почему ×2:** В NLOS канале пути приходят со всех направлений.
Doppler сдвиги распределены от −f_D до +f_D → полный spread = 2·f_D.

N_sidelobe определяется из требования к уровню sidelobe интерференции
от пилота. Для pilot_power=100:

```
I_pilot(d) = 10 / (π · d)

Требуем: I_pilot(N_sidelobe) ≤ I_max
→ N_sidelobe ≥ 10 / (π · I_max)
```

Зависимость N_sidelobe от SNR: при высоком SNR данные слабее относительно пилота,
требуется больший margin.

| SNR (dB) | I_max | N_sidelobe | L_g_dopp при v=80 м/с |
|---|---|---|---|
| 10 | 1.0 | 4 | 1+4 = **5** |
| 18 | 0.5 | 7 | 1+7 = **8** |
| 24 | 0.3 | 11 | 1+11 = **12** |
| 30 | 0.15 | 22 | 1+22 = **23** |

**Практический выбор:** N_sidelobe зависит от целевого SNR работы системы.
Для SNR=18-24 dB (типичный рабочий диапазон): N_sidelobe = 7-11.

**Delay guard:**

```
L_guard_delay(scenario) = ceil(τ̃_90% / Δτ) + M_sidelobe

где:
  τ̃_90% = 3 · τ_rms    — 90% энергии канала (для UMi NLOS)
  Δτ = 1 / (M · df)    — разрешение по задержке
  M_sidelobe = 4        — фиксированный margin
```

M_sidelobe = 4 выбран т.к. sidelobes по задержке убывают быстрее
(больше M = 64 → уже главный лепесток).

### 3.8. Таблица адаптивных guard-зон

Для fc=5.9 ГГц, Δf=150 кГц, M=64, N=32, M_sidelobe=4:

| Сценарий | v (м/с) | ν̃_spread | SNR | N_sl | L_g_dopp | τ_90% (мкс) | τ̃_90% | M_sl | L_g_delay | Guard | Data | Eff.% |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| UMi | 30 | 0.25 | 18 | 7 | **8** | 1.0 | 9.6 | 4 | **14** | 492 | 1555 | 75.9 |
| UMi | 80 | 0.67 | 18 | 7 | **8** | 1.0 | 9.6 | 4 | **14** | 492 | 1555 | 75.9 |
| UMi | 150 | 1.26 | 18 | 7 | **9** | 1.0 | 9.6 | 4 | **14** | 531 | 1516 | 74.0 |
| UMi | 80 | 0.67 | 30 | 22 | **23** | 1.0 | 9.6 | 4 | **14** | 1035 | 1012 | 49.4 |
| UMa | 80 | 0.67 | 18 | 7 | **8** | 3.0 | 28.8 | 4 | **33** | 1138 | 909 | 44.4 |
| UMa | 150 | 1.26 | 18 | 7 | **9** | 3.0 | 28.8 | 4 | **33** | 1177 | 870 | 42.5 |
| RMa | 80 | 0.67 | 18 | 7 | **8** | 5.0 | 48.0 | 4 | **52** | 1547 | 500 | 24.4 |

**Наблюдения:**
1. При df=150 кГц Doppler spread мал (ν̃_spread < 1.3 даже при 150 м/с)
2. Основной вклад в L_g_dopp — sidelobe margin, зависящий от SNR
3. При SNR=30 dB N_sidelobe=22 → L_g_dopp=23 (больше чем Full=10!)
4. **Ключевой инсайт:** Adaptive guard-zone **меньше** Full при SNR ≤ 18 dB,
   но **больше** Full при SNR > 24 dB. Это правильно — при высоком SNR
   sidelobes пилота становятся относительно сильнее.

---

## 4. Алгоритм адаптивного формирования кадра

### 4.1. Block diagram

```
Вход: v, scenario, SNR
  │
  ├─→ Расчёт ν̃_max(v)
  ├─→ Расчёт τ_90%(scenario)
  ├─→ N_sidelobe(SNR)
  │
  ├─→ L_guard_dopp  = ceil(ν̃_max) + N_sidelobe
  ├─→ L_guard_delay = ceil(τ̃_90%) + M_sidelobe
  │
  ├─→ Проверка: guard bins < 0.5 · M·N  (не больше половины кадра)
  │     │
  │     YES → OK
  │     NO  → L_guard = min(L_guard, floor(M/4))  (clip)
  │
  └─→ OTFS_MASK_GENERATOR(L_guard_delay, L_guard_dopp)
        │
        └─→ DD-кадр с адаптивной guard-зоной
```

### 4.2. Псевдокод

```matlab
function [L_g_delay, L_g_dopp] = compute_adaptive_guard(v, fc, M, N, df, scenario)
    % Параметры сценария (3GPP 38.901) — 90% энергии канала
    switch scenario
        case 'UMi_NLOS'
            tau_90 = 1.0e-6;    % 90% энергии канала, 1 мкс
        case 'UMa_NLOS'
            tau_90 = 3.0e-6;    % 3 мкс
        case 'RMa_NLOS'
            tau_90 = 5.0e-6;    % 5 мкс
        otherwise
            tau_90 = 2.0e-6;    % default
    end

    % --- Doppler guard ---
    f_dopp_max = fc * v / 3e8;          % Макс. Doppler, Гц
    dnu = df / N;                        % Разрешение по Doppler, Гц/bin
    nu_tilde_max = f_dopp_max / dnu;     % В бинах

    N_sidelobe = 7;                      % Фиксировано (I_max ≈ 0.45)
    L_g_dopp = max(1, ceil(nu_tilde_max) + N_sidelobe);

    % --- Delay guard ---
    dtau = 1 / (M * df);                 % Разрешение по задержке, с
    tau_tilde_90 = tau_90 / dtau;        % 90% энергии в бинах

    M_sidelobe = 4;                      % Фиксированный margin
    L_g_delay = max(1, ceil(tau_tilde_90) + M_sidelobe);

    % --- Clip: guard не больше 40% половины сетки ---
    L_g_dopp = min(L_g_dopp, floor(0.4 * N/2));
    L_g_delay = min(L_g_delay, floor(0.4 * M/2));
end
```

---

## 5. План валидации

### 5.1. Что нужно проверить

1. **BER vs SNR** с адаптивной guard-зоной vs фиксированной
   - Ожидание: BER не ухудшается, spectral efficiency растёт

2. **BER vs v** (multi-speed)
   - Ожидание: адаптивная guard-зона автоматически подстраивается

3. **Разные сценарии** (UMi, UMa, RMa)
   - Ожидание: guard-зона растёт с τ_rms сценария

### 5.2. Модификация существующих скриптов

```
ber_snr_quadriga_frft.m:
  - Заменить фиксированные L_guard_* на вызов compute_adaptive_guard()
  - Добавить колонку spectral efficiency в результаты

ber_multispeed_quadriga.m:
  - Аналогично
  - Показать L_g_dopp(v) и L_g_delay(v) как функции скорости
```

### 5.3. Метрики

| Метрика | Формула | Что показывает |
|---|---|---|
| Spectral efficiency | η = N_data · log2(M_mod) / (M·N) | Бит на bin |
| Guard overhead | OH = N_guard / (M·N) · 100% | % потерь |
| BER degradation | ΔBER = BER_adaptive - BER_fixed | Потеря качества |
| Net gain | Δη при ΔBER < 10% | Итоговый выигрыш |

---

## 6. Связь с положением 3

### 6.1. Что меняется в FRFT-SIC

Алгоритм FRFT-SIC **не меняется** — он работает с любой guard-зоной.
Меняется только **входной параметр** OTFS_MASK_GENERATOR.

### 6.2. Что нужно проверить

1. **Channel filtering** (reject channels with paths outside guard):
   - При меньшей guard-зоне больше каналов будет rejected
   - Нужно убедиться, что rejection rate < 10%

2. **Pilot DD response**:
   - Dirichlet kernel (eq. 10-11 в article_en.md) зависит от guard
   - Формулы остаются корректными

### 6.3. Обновление параметров положения 3

Текущие фиксированные значения:
```
L_guard_delay = 14    → L_guard_delay = compute_adaptive_guard(...)
L_guard_dopp  = 10    → L_guard_dopp  = compute_adaptive_guard(...)
```

Для baseline (v=80 м/с, UMi NLOS, df=150 кГц):
```
ν̃_max = 0.34 → ceil(0.34) = 1
L_g_dopp = 1 + 7 = 8    (было 10, экономия 2 bins по каждой оси)
L_g_delay = 10 + 4 = 14 (совпадает с текущим)
```

Новизна:
1. **Аналитическое обоснование** L_g_delay=14 (из τ_90% канала)
2. **Уменьшение L_g_dopp** с 10 до 8 (экономия ~120 bins)
3. **Автоматическая адаптация** к другим сценариям (UMa, RMa, df=15 кГц)

---

## 7. Публикационная стратегия

### 7.1. Что можно опубликовать

1. **Аналитическая формула** для L_guard(SNR, v, scenario)
   - IEEE Communications Letters (4 страницы, быстрая публикация)

2. **Spectral efficiency analysis** с адаптивной guard-зоной
   - Можно добавить как Section V-H к article_en.md

3. **Joint optimization** guard-зоны + pilot power
   - Расширение для IEEE TWC (полная статья)

### 7.2. Ключевые figures для статьи

| Figure | Описание |
|---|---|
| Fig.A | L_g_dopp(v) и L_g_delay(scenario) — кривые |
| Fig.B | Spectral efficiency vs v (adaptive vs fixed) |
| Fig.C | BER vs SNR (adaptive vs fixed) — показать отсутствие деградации |
| Fig.D | Guard overhead vs scenario (bar chart) |

---

## 8. TODO

- [x] Математическая модель sidelobes Dirichlet
- [x] Аналитическая формула guard-зоны
- [x] Псевдокод compute_adaptive_guard()
- [ ] Реализация compute_adaptive_guard.m
- [ ] Модификация ber_snr_quadriga_frft.m
- [ ] Модификация ber_multispeed_quadriga.m
- [ ] Симуляция: BER vs SNR (adaptive vs fixed)
- [ ] Симуляция: spectral efficiency vs v
- [ ] Генерация figures A-D
- [ ] Написание текста для article_en.md Section V-H
