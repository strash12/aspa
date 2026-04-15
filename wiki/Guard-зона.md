# Guard-зона

## Описание
Защитная зона из нулевых символов вокруг пилота в DD-области. Предотвращает интерференцию пилота с данными из-за дробного Допплера и многолучевости.

## Связи
- [[Adaptive guard]] — адаптивный размер guard-зоны
- [[Положение 1]] — формирование кадра с guard-зоной
- [[Delay-Doppler сетка]] — guard размещается в DD-бинах
- [[OTFS параметры]] — фиксированные параметры guard

## Теги
#guard #pilot #interference #OTFS

## Содержание

### Фиксированные варианты
| Тип | L_g_dopp | L_g_delay | Guard bins | Data bins | Efficiency |
|---|---|---|---|---|---|
| Reduced | 4 | 6 | 116 | 1931 | 94.3% |
| Full | 10 | 14 | 608 | 1439 | 70.3% |

### Формула размера
```
N_guard = (2·L_g_delay + 1) × (2·L_g_dopp + 1) - 1
N_data = M×N - 1 - N_guard
Efficiency = N_data / (M×N) × 100%
```

### Позиция пилота
```
k_p = N/2 = 16  (по Допплеру)
l_p = M/2 = 32  (по задержке)
```

Guard-зона: `[k_p - L_g_dopp, k_p + L_g_dopp] × [l_p - L_g_delay, l_p + L_g_delay]`

## Источники
- `position_1/POSITION_1_CONTEXT.md`
- `position_1/ADAPTIVE_GUARD_ZONE.md`
