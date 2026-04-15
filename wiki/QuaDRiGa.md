# QuaDRiGa

## Описание
QuaDRiGa (Quasi Deterministic Radio Channel Generator) — генератор каналов 3GPP 38.901. Используется для генерации реалистичных многолучевых каналов с параметрами (delay spread, Doppler spread, angular spread).

## Связи
- [[3GPP 38.901 UMi NLOS]] — сценарий Urban Microcell
- [[3GPP 38.901 UMa NLOS]] — сценарий Urban Macrocell
- [[3GPP 38.901 RMa NLOS]] — сценарий Rural Macrocell
- [[Adaptive guard]] — использует QuaDRiGa для извлечения delay spread

## Теги
#channel_model #3GPP #simulation

## Содержание

### Версия
v2.8.1, расположена в `documentation/quadriga_src/`

### Использование
```matlab
s = qd_simulation_parameters;
s.center_frequency = fc;
l = qd_layout(s);
l.no_rx = 100;
l.randomize_rx_positions(200, 1.5, 1.5, 1.7);
l.set_scenario('3GPP_38.901_UMi_NLOS');
p = l.init_builder;
p.gen_parameters;
c = p.get_channels;
```

### Извлечение delay spread
Из `c.coeff` и `c.delay` извлекаются мощности и задержки путей, затем вычисляется tau_90 (delay, в котором накоплено 90% энергии).

### Tutorials
15 tutorials в `documentation/tutorials/`:
- t01: handles (common mistake)
- t07: parameter generation
- t08: time evolution / drifting
- t14: dual mobility

## Источники
- `documentation/quadriga_src/`
- `position_1/adaptive_guard_quadriga.m`
