# -*- coding: utf-8 -*-
"""
adaptive_guard_comparison.py
Сравнение трёх подходов к guard-зоне в OTFS:
  1. Reduced guard  — L_g_dopp=4, L_g_delay=6  (минимальная)
  2. Full guard     — L_g_dopp=10, L_g_delay=14 (фиксированная, Raviteja)
  3. Adaptive guard — оптимизированная под scenario (предложенный метод)

Ключевая идея:
- Delay guard определяется delay spread канала (scenario-dependent)
- Doppler guard определяется sidelobes пилота + fractional Doppler
- FRFT-SIC компенсирует остаточную интерференцию, поэтому не нужно
  требовать "интерференция ниже шума"

Формула:
  L_g_delay = ceil(tau_90 / dtau) + M_sidelobe    (scenario-dependent)
  L_g_dopp  = ceil(nu_spread) + N_sidelobe         (speed-dependent)

где nu_spread = 2*f_D/dnu (полный Doppler spread в NLOS)
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import os

# ============================================================
#  Параметры OTFS (из положения 3)
# ============================================================
M = 64            # Поднесущие
N = 32            # Допплер-бины
df = 150e3        # Межподнесущий интервал, Гц
fc = 5.9e9        # Несущая частота, Гц
T = 1 / df
pilot_power = 100
pilot_amp = np.sqrt(pilot_power)  # = 10

# ============================================================
#  Сценарии (3GPP 38.901)
# ============================================================
scenarios = [
    {'name': 'UMi_NLOS', 'tau_90': 1.0e-6},
    {'name': 'UMa_NLOS', 'tau_90': 3.0e-6},
    {'name': 'RMa_NLOS', 'tau_90': 5.0e-6},
]

speeds = np.array([10, 30, 50, 80, 120, 150, 200])  # м/с

# ============================================================
#  Fixed guard zones
# ============================================================
guard_reduced = {'dopp': 4, 'delay': 6}
guard_full     = {'dopp': 10, 'delay': 14}

# ============================================================
#  Adaptive guard
# ============================================================
def compute_adaptive_guard(scenario, v):
    """
    Адаптивная guard-зона.

    Delay guard: из delay spread канала
    Doppler guard: из Doppler spread + sidelobes

    FRFT-SIC компенсирует остаточную интерференцию,
    поэтому N_sidelobe можно взять меньше чем в Full.
    """
    tau_90 = scenario['tau_90']

    # Разрешение
    dtau = 1.0 / (M * df)
    dnu = df / N

    # Delay guard
    tau_tilde_90 = tau_90 / dtau
    M_sidelobe = 4
    L_g_delay = int(np.ceil(tau_tilde_90)) + M_sidelobe

    # Doppler guard
    f_dopp = fc * v / 3e8
    nu_spread = 2 * f_dopp / dnu  # полный spread
    N_sidelobe = 7  # FRFT-SIC компенсирует остаток
    L_g_dopp = max(1, int(np.ceil(nu_spread)) + N_sidelobe)

    # Clip
    L_g_dopp = max(1, min(L_g_dopp, N // 2 - 1))
    L_g_delay = max(1, min(L_g_delay, M // 2 - 1))

    return L_g_dopp, L_g_delay


# ============================================================
#  Расчёт
# ============================================================
print('=' * 120)
print('=== Сравнение guard-зон: Reduced vs Full vs Adaptive ===')
print('=' * 120)

results = {}

for sc in scenarios:
    for v in speeds:
        L_ad_d, L_ad_dl = compute_adaptive_guard(sc, v)

        key = f"{sc['name']}_v{v}"
        results[key] = {'scenario': sc['name'], 'v': v}

        for name, L_d, L_dl in [('Reduced', guard_reduced['dopp'], guard_reduced['delay']),
                                 ('Full', guard_full['dopp'], guard_full['delay']),
                                 ('Adaptive', L_ad_d, L_ad_dl)]:
            N_guard = (2 * L_dl + 1) * (2 * L_d + 1) - 1
            N_data = M * N - 1 - N_guard
            if N_data < 0:
                N_data = 0
                N_guard = M * N - 1
            efficiency = N_data / (M * N) * 100

            I_pilot = pilot_amp / (np.pi * max(L_d, 0.5))
            SNR_req = 10 * np.log10(1.0 / I_pilot**2)

            results[key][name] = {
                'L_g_dopp': L_d,
                'L_g_delay': L_dl,
                'N_guard': N_guard,
                'N_data': N_data,
                'efficiency': efficiency,
                'I_pilot': I_pilot,
                'SNR_req': SNR_req,
            }

# ============================================================
#  Таблица
# ============================================================
print(f"\n{'Scenario':<12s} {'v':>5s} {'Method':>8s} {'L_g_d':>6s} {'L_g_dl':>7s} "
      f"{'Guard':>6s} {'Data':>6s} {'Eff.%':>7s} {'I_pilot':>9s} {'SNR_req':>8s}")
print('-' * 100)

for sc in scenarios:
    for v in speeds:
        key = f"{sc['name']}_v{v}"
        r = results[key]
        for name in ['Reduced', 'Full', 'Adaptive']:
            d = r[name]
            print(f"{sc['name']:<12s} {v:>5d} {name:>8s} {d['L_g_dopp']:>6d} {d['L_g_delay']:>7d} "
                  f"{d['N_guard']:>6d} {d['N_data']:>6d} {d['efficiency']:>6.1f} "
                  f"{d['I_pilot']:>9.4f} {d['SNR_req']:>7.1f}")
    print()

# ============================================================
#  Визуализация
# ============================================================
output_dir = os.path.dirname(os.path.abspath(__file__))
colors = ['#1f77b4', '#ff7f0e', '#2ca02c']

# --- Figure 1: Guard zone sizes vs speed ---
fig, axes = plt.subplots(2, 2, figsize=(14, 10))

for si, sc in enumerate(scenarios):
    ax = axes.flat[si]
    L_d_ad, L_dl_ad = [], []

    for v in speeds:
        key = f"{sc['name']}_v{v}"
        L_d_ad.append(results[key]['Adaptive']['L_g_dopp'])
        L_dl_ad.append(results[key]['Adaptive']['L_g_delay'])

    ax.plot(speeds, L_d_ad, '^-', color=colors[2], linewidth=2, markersize=8, label='L_g_dopp Adaptive')
    ax.plot(speeds, L_dl_ad, 's-', color=colors[2], linewidth=2, markersize=8, label='L_g_delay Adaptive')
    ax.axhline(y=guard_full['dopp'], color=colors[1], linestyle='--', alpha=0.7, label='L_g_dopp Full')
    ax.axhline(y=guard_full['delay'], color=colors[1], linestyle=':', alpha=0.7, label='L_g_delay Full')
    ax.axhline(y=guard_reduced['dopp'], color=colors[0], linestyle='-.', alpha=0.5, label='L_g_dopp Reduced')
    ax.axhline(y=guard_reduced['delay'], color=colors[0], linestyle=':', alpha=0.5, label='L_g_delay Reduced')

    ax.set_xlabel('Speed, m/s')
    ax.set_ylabel('L_{guard}')
    ax.set_title(sc['name'])
    ax.legend(loc='upper left', fontsize=7)
    ax.grid(True, alpha=0.3)

fig.suptitle('Guard-zone sizes: Reduced vs Full vs Adaptive', fontsize=14, fontweight='bold')
fig.tight_layout()
fig.savefig(os.path.join(output_dir, 'fig_guard_vs_speed.png'), dpi=150, bbox_inches='tight')
plt.close(fig)
print("Saved: fig_guard_vs_speed.png")

# --- Figure 2: Spectral efficiency vs speed ---
fig, axes = plt.subplots(1, 3, figsize=(14, 5))

for si, sc in enumerate(scenarios):
    ax = axes[si]
    eff_r, eff_f, eff_a = [], [], []
    for v in speeds:
        key = f"{sc['name']}_v{v}"
        eff_r.append(results[key]['Reduced']['efficiency'])
        eff_f.append(results[key]['Full']['efficiency'])
        eff_a.append(results[key]['Adaptive']['efficiency'])

    ax.plot(speeds, eff_r, 'o--', color=colors[0], linewidth=1.5, markersize=6, label='Reduced')
    ax.plot(speeds, eff_f, 's--', color=colors[1], linewidth=1.5, markersize=6, label='Full')
    ax.plot(speeds, eff_a, '^-', color=colors[2], linewidth=2, markersize=8, label='Adaptive')

    ax.set_xlabel('Speed, m/s')
    ax.set_ylabel('Spectral efficiency, %')
    ax.set_title(sc['name'])
    ax.legend(loc='lower left')
    ax.grid(True, alpha=0.3)

fig.suptitle('Spectral efficiency vs speed', fontsize=14, fontweight='bold')
fig.tight_layout()
fig.savefig(os.path.join(output_dir, 'fig_efficiency_vs_speed.png'), dpi=150, bbox_inches='tight')
plt.close(fig)
print("Saved: fig_efficiency_vs_speed.png")

# --- Figure 3: Gain Adaptive vs Full ---
fig, axes = plt.subplots(1, 3, figsize=(14, 4))

for si, sc in enumerate(scenarios):
    ax = axes[si]
    gain = []
    for v in speeds:
        key = f"{sc['name']}_v{v}"
        gain.append(results[key]['Adaptive']['efficiency'] - results[key]['Full']['efficiency'])

    ax.bar(speeds, gain, color=colors[2])
    ax.set_xlabel('Speed, m/s')
    ax.set_ylabel('Delta Efficiency, %')
    ax.set_title(sc['name'])
    ax.grid(True, alpha=0.3, axis='y')
    ax.axhline(y=0, color='k', linestyle='--', linewidth=0.5)

fig.suptitle('Gain: Adaptive vs Full (positive = better than Full)', fontsize=14, fontweight='bold')
fig.tight_layout()
fig.savefig(os.path.join(output_dir, 'fig_adaptive_gain.png'), dpi=150, bbox_inches='tight')
plt.close(fig)
print("Saved: fig_adaptive_gain.png")

# ============================================================
#  Summary
# ============================================================
print(f"\n{'='*80}")
print(f'=== SUMMARY: Adaptive vs Full ===')
print(f"{'='*80}")

for sc in scenarios:
    print(f"\n{sc['name']}:")
    better = 0
    worse = 0
    for v in speeds:
        key = f"{sc['name']}_v{v}"
        eff_a = results[key]['Adaptive']['efficiency']
        eff_f = results[key]['Full']['efficiency']
        if eff_a > eff_f:
            better += 1
        elif eff_a < eff_f:
            worse += 1
    print(f"  Adaptive better: {better}/{len(speeds)} speeds")
    print(f"  Adaptive worse:  {worse}/{len(speeds)} speeds")

# Key numbers
print(f"\n{'='*80}")
print(f'=== Key numbers (UMi_NLOS) ===')
print(f"{'='*80}")
for v in [30, 80, 150]:
    key = f"UMi_NLOS_v{v}"
    r = results[key]
    print(f"\nv={v} m/s:")
    for name in ['Reduced', 'Full', 'Adaptive']:
        d = r[name]
        print(f"  {name:>8s}: L_g_dopp={d['L_g_dopp']:>3d}, L_g_delay={d['L_g_delay']:>3d}, "
              f"eff={d['efficiency']:.1f}%, I_pilot={d['I_pilot']:.4f}")

print('\nDone.')
