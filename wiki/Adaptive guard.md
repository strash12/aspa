# Adaptive guard

## Описание
Адаптивная guard-зона — размер guard определяется реальными параметрами канала (delay spread, Doppler spread), а не фиксированными значениями.

## Связи
- [[Guard-зона]] — базовая концепция guard-зоны
- [[QuaDRiGa]] — источник реальных параметров канала
- [[3GPP 38.901 UMi NLOS]] — сценарий с малым delay spread
- [[3GPP 38.901 UMa NLOS]] — сценарий со средним delay spread
- [[3GPP 38.901 RMa NLOS]] — сценарий с большим delay spread
- [[Положение 1]] — реализация adaptive guard

## Теги
#adaptive #guard #optimization #QuaDRiGa

## Содержание

### Формула
```
Delay guard:  L_g_delay = ceil(tau_90 / dtau) + M_sidelobe
Doppler guard: L_g_dopp  = ceil(nu_spread / dnu) + N_sidelobe
```
где `tau_90` — median delay spread из QuaDRiGa, `nu_spread` — Doppler spread из скорости.

### Результаты (QuaDRiGa-based, median по 100 RX)
| Сценарий | tau_90 | L_g_dopp | L_g_delay | Efficiency | vs Full |
|---|---|---|---|---|---|
| UMi_NLOS | 0.20 мкс | 8 | 6 | 89.2% | +18.9% |
| UMa_NLOS | 0.81 мкс | 8 | 12 | 79.2% | +8.9% |
| RMa_NLOS | 0.08 мкс | 8 | 5 | 90.9% | +20.6% |

### Ключевой вывод
Adaptive guard **всегда лучше** фиксированного Full (7/7 для всех сценариев), потому что использует median delay spread из реальных каналов, а не worst-case из таблиц.

## Источники
- `position_1/adaptive_guard_quadriga.m`
- `position_1/ADAPTIVE_GUARD_ZONE.md`
