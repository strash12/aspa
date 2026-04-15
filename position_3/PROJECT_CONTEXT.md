# OTFS FRFT-SIC Channel Estimation — Project Context

## Project Overview

Developing an OTFS channel estimation algorithm (FRFT-SIC with multi-pass refinement) evaluated on QuaDRiGa-generated 3GPP 38.901 channels. Goal: publish academic paper. The algorithm has been fully debugged, validated, and produces publication-quality results.

---

## OTFS System Parameters (FINAL)

```
M=64, N=32, padType='ZP', padLen=12, df=150e3
fc=5.9 GHz, scenario=3GPP_38.901_UMi_NLOS
Np_keep=4, mod_size=4 (QPSK)
pilot_power=100, pilot_delay_idx=M/2, pilot_dopp_idx=N/2
L_guard_delay=14, L_guard_dopp=10
```

FRFT-SIC parameters:
```
N_fine=91, SIC_threshold_k=3.0, max_paths_sic=6
residual_stop_dB=-20, N_refine_passes=6, prune_ratio=0.08
Radius schedule: [0.40, 0.40, 0.20, 0.20, 0.10, 0.10]
```

LMMSE equalizer: truncated-SVD with floor
```
α_floor = 1e-3 (n0_eff = max(n0, 1e-3 * σ_max²))
α_tol = 1e-10 (truncation tolerance)
```

---

## Algorithm: FRFT-SIC with Multi-Pass Refinement

4-stage pipeline:
1. **Initial SIC**: greedy peak search in Hdd → fine 2D FRFT correlation (91×91 grid) → parabolic interpolation → LS gain → residual update. Up to 6 iterations.
2. **Joint LS re-estimation**: A\r for all found paths simultaneously (corrects bias from greedy extraction).
3. **Pruning**: remove paths with |gain| < 8% of max. Re-apply joint LS on remaining.
4. **Multi-pass refinement**: 6 passes, each:
   - Leave-one-out residual for each path
   - Narrow fine search (31×31) with adaptive radius [0.4,0.4,0.2,0.2,0.1,0.1]
   - Parabolic interpolation
   - Joint LS after each pass
   - Final pruning

---

## Key Files (all in project knowledge + outputs)

### MATLAB simulation scripts (in outputs/):
| File | Purpose |
|---|---|
| `ber_snr_quadriga_frft.m` | Main BER vs SNR script (TRUE vs FRFT-SIC), 500 trials, SVD-LMMSE with floor |
| `ablation_study.m` | Ablation V0-V4 (200 trials, shared channels/noise via fixed seeds) |
| `replot_ablation.m` | Re-renders ablation plots from ablation_results.mat |
| `ber_multispeed_quadriga.m` | Multi-speed sweep (v=30/80/150) + NMSE + parameter error metrics |
| `lmmse_comparison.m` | 3 equalizer variants (direct/SVD-nofloor/SVD-floor) × (TRUE/FRFT) |
| `baseline_comparison.m` | 4 estimation methods: Threshold(Raviteja)/SIC-only(V0)/Proposed(V4)/TRUE |
| `fig1_fractional.m` | Generates Fig.1 (fractional Doppler spreading illustration) |
| `algorithm1.docx` | Algorithm 1 pseudocode formatted for Word insertion |

### Helper functions (in project knowledge, user uploads):
| File | Purpose |
|---|---|
| `helperOTFSmod.m` | OTFS modulator (DD → time domain) |
| `helperOTFSdemod.m` | OTFS demodulator (time domain → DD) |
| `getG_fractional.m` | Channel matrix builder G (verified to machine precision -295dB) |
| `OTFS_MASK_GENERATOR.m` | DD frame mask generator (pilot/guard/data regions) |

### Article drafts (in outputs/):
| File | Purpose |
|---|---|
| `article_en.md` | English article — Sections I-V (726 lines, ~90% complete) |
| `article_ru.md` | Russian article — Sections I-II only |

---

## Completed Simulation Results

### 1. Final BER vs SNR (500 trials, v=80 m/s)
```
SNR=  0 dB | TRUE=3.417e-01 | FRFT=3.417e-01
SNR= 10 dB | TRUE=1.125e-01 | FRFT=1.139e-01
SNR= 18 dB | TRUE=6.396e-03 | FRFT=7.990e-03
SNR= 20 dB | TRUE=1.766e-03 | FRFT=2.844e-03
SNR= 24 dB | TRUE=6.798e-05 | FRFT=3.372e-04
SNR= 30 dB | TRUE=1.328e-05 | FRFT=1.450e-04
SNR= 40 dB | TRUE=1.646e-05 | FRFT=1.402e-04
```
Data saved in `ber_quadriga_frft.mat`.

### 2. Ablation Study (200 trials, v=80 m/s)
At SNR=30 dB:
```
V0 (Baseline SIC):           2.68e-3
V1 (+Parabolic):             2.58e-3  (×1.0 improvement)
V2 (+Joint LS):              1.32e-3  (×1.9 improvement)
V3 (+Pruning):               1.34e-3  (×1.0 improvement)
V4 (+Multi-pass refinement): 2.48e-4  (×5.4 improvement)
TOTAL V0→V4: ×10.8
```
Key insight: Pruning alone does nothing (×1.0) but is a PREREQUISITE for multi-pass refinement (×5.4). Components are synergistic, not additive.
Data saved in `ablation_results.mat`.

### 3. LMMSE Equalizer Comparison (100 trials, v=80 m/s)
At SNR=30 dB (FRFT estimation):
```
Direct LMMSE (eq.13):     ~1e-2   (stuck at high floor)
SVD no floor:             ~1e-2   (same problem)
SVD with floor (proposed): ~2e-4  (×50 better)
```
For TRUE channel: all 3 variants are IDENTICAL — floor doesn't hurt when channel is exact.
Data saved in `lmmse_comparison.mat`.

### 4. Scripts launched but results pending:
- `ber_multispeed_quadriga.m` — multi-speed sweep with NMSE metrics (v=30/80/150)
- `baseline_comparison.m` — comparison with Threshold(Raviteja)/SIC-only/Proposed/TRUE

---

## Article Structure (article_en.md — current state)

### Completed sections:
- **Abstract** — with numerical example (v=120km/h, ν̃=1.66 bins)
- **Section I (Introduction)** — motivation, Table I (fractional Doppler for 4 velocities), related work review, 4 contributions, figure placeholder Fig.1 (fractional spreading)
- **Section II (System Model)** — II-A OTFS modulation (eq 1-3), II-B multipath DD channel (eq 4-6), II-C matrix model r=Gs+w (eq 7-9), II-D frame structure with embedded pilot, II-E pilot DD response with Dirichlet kernel (eq 10-11), II-F problem formulation (eq 12-13). Figure placeholders: Fig.2 (TX/RX block diagram), Fig.3 (frame structure)
- **Section III (Proposed Algorithm)** — III-A Initial SIC with FRFT fine search (eq 14-24), III-B Joint LS re-estimation (eq 25-26), III-C Path pruning (eq 27), III-D Multi-pass refinement (eq 28-31), III-E Algorithm 1 pseudocode (38 lines), III-F Computational complexity (eq 32-34, ~7×10⁸ ops, ~100× faster than SBL)
- **Section IV (LMMSE Equalization)** — IV-A Motivation/failure modes, IV-B Truncated-SVD with floor (eq 35-39), IV-C Equivalence proof (eq 40), IV-D Computational cost, IV-E Application to both TRUE and estimated channels
- **Section V (Simulation Results)** — V-A Setup (Table II, Fig.4-6 placeholders), V-B Ablation study (complete text with Figs.7-8), V-C BER vs SNR main result (complete text with Fig.9)

### Placeholder sections (text structure ready, awaiting data):
- **V-D** Channel estimation NMSE and parameter errors (needs multi-speed results)
- **V-E** Impact of velocity (needs multi-speed results)
- **V-F** LMMSE equalizer comparison (data now available from lmmse_comparison)

### Not yet written:
- **V-G** Baseline comparison with other methods (Threshold/SIC-only/Proposed) — script ready
- **Section VI (Conclusion)**

### References [1]-[16]:
[1] Wang - 6G vision, [2] Wei - OTFS waveform, [3] Raviteja - embedded pilot (MAIN ref), [4] Hadani - OTFS original, [5] Wei - off-grid SBL, [6] Zhao - SBL delay-Doppler, [7] Rasheed - sparse DD, [8] Wei - 2D off-grid, [9] Liu - MP-based SSR, [10] Shan - low-complexity, [11] Qu - MUSIC, [12] Shi - pilot design MIMO-OTFS, [13] Cheng - MatNet, [14] Zhang - DL OTFS, [15] Jaeckel - QuaDRiGa, [16] Ozaktas - FRFT book

---

## Available Figures (already generated)

| Figure | Content | File/Source |
|---|---|---|
| Fig.1 | Fractional Doppler spreading (3 subplots) | `fig1_fractional.m` — run on MATLAB |
| Fig.2 | OTFS TX/RX block diagram | Reuse from previous paper (статья_v1.docx) |
| Fig.3 | DD frame structure with pilot | Reuse from previous paper |
| Fig.4 | QuaDRiGa scene topology (500 RX) | Already have PNG (BS + 500 dots) |
| Fig.5 | Path delay/Doppler scatter + guard zone | Already have PNG |
| Fig.6 | PDP of representative channel (Np=4) | Already have PNG |
| Fig.7 | Ablation BER curves (V0-V4 + TRUE + Raw) | Already have PNG |
| Fig.8 | Per-component improvement bar chart | Already have PNG |
| Fig.9 | Final 500-trial BER vs SNR | Already have PNG |
| Fig.10 | LMMSE equalizer comparison (6 curves) | Already have PNG |
| Fig.11 | Baseline comparison (4 methods) | Pending — script ready |

---

## Key Debugging History (resolved issues)

1. **getG_fractional verified correct** — matches direct channel model to -295 dB
2. **Noise scaling fix**: Es_td from time-domain rx_block, not DD-domain
3. **Channel filtering**: reject channels with paths outside guard zone (~3-5% rejection)
4. **Doppler extraction from QuaDRiGa**: numerical differentiation with 2 snapshots
5. **LMMSE truncated-SVD with floor**: prevents noise amplification at high SNR from estimation errors
6. **Stepwise radius schedule**: fixed non-monotonic BER at SNR=25 dB (was caused by adaptive radius overshoot)
7. **SVD without floor catastrophe**: at high SNR, estimation errors amplified → added floor α=10⁻³

---

## Key Design Decisions

1. df=15 kHz for motivating example (more dramatic fractional), df=150 kHz for simulations
2. Reject channels with paths outside guard zone (don't try to handle them)
3. Use truncated-SVD LMMSE with floor=max(n0, 1e-3·s_max²) for BOTH TRUE and FRFT
4. Algorithm name: FRFT-SIC (eq.19 shows operation is FRFT)
5. Forward additive ablation (V0→V4), not leave-one-out
6. Article focus: synergy of 4 components, not any single one
7. Work on English article first, translate to Russian later

---

## Immediate TODO List

### High priority (for paper completion):
- [ ] Fill V-F with LMMSE comparison text (data ready from Fig.10)
- [ ] Run `baseline_comparison.m` → get Fig.11 → write V-G
- [ ] Write Section VI (Conclusion)
- [ ] Fill V-D and V-E when multi-speed results arrive
- [ ] Fix abstract: change "~1 dB" to "~1 dB at practical BER levels (10⁻³–10⁻²)"
- [ ] Run `fig1_fractional.m` on MATLAB → insert Fig.1

### Medium priority:
- [ ] Translate completed article to Russian (article_ru.md has only Sections I-II)
- [ ] Leave-one-out ablation (optional: proves pruning is enabler for refinement)
- [ ] Convergence analysis of refinement passes (BER vs N_refine_passes)

### Low priority / future work:
- [ ] 16-QAM/64-QAM evaluation
- [ ] Multi-scenario (UMa, RMa, InH)
- [ ] CRLB comparison
- [ ] Pilot power sensitivity analysis
- [ ] Confidence intervals on BER curves
- [ ] Efficient banded LMMSE implementation

---

## How to Continue

1. Upload this context file to a new Claude chat along with the project files
2. The article draft is in `article_en.md` — all formulas are numbered (1)-(40) with consistent notation
3. All MATLAB scripts are self-contained with `lmmse_svd_floor()` function included
4. Key .mat files on your machine: `ber_quadriga_frft.mat`, `ablation_results.mat`, `lmmse_comparison.mat`
5. The previous user-uploaded files (статья_v1.docx, статья2.docx) contain the Russian version of a related earlier paper on OTFS frame design — useful for terminology consistency

---

## Notation Reference (consistent across all sections)

| Symbol | Meaning |
|---|---|
| M, N | Subcarriers, Doppler bins (64, 32) |
| Δf, T | Subcarrier spacing, subsymbol duration |
| Δτ, Δν | Delay/Doppler resolution (1/MΔf, 1/NT) |
| τ̃_p, ν̃_p | Normalized delay/Doppler in grid bins |
| h_p, τ_p, ν_p | Path gain, delay, Doppler (physical units) |
| G | Channel matrix (N_s × N_s) |
| x_p | Pilot amplitude |
| (k_p, l_p) | Pilot position in DD grid (N/2, M/2) |
| Hdd | DD-domain channel response |
| K(·,·) | 2D Dirichlet kernel |
| u(d,f) | Time-domain reference vector for path at (d,f) |
| A | Matrix of reference vectors [u₁ ... u_P] |
| σ²_{w,eff} | Effective noise variance with floor |
| α_floor | Regularization floor ratio (10⁻³) |
| R_r | Refinement search radius at pass r |
