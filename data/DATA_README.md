# Datasets — README and data dictionary

The `data/` folder ships with **four CSVs**: two real (cleared for publication) and two synthetic. All four share the same analysis columns, so the pipeline is identical whichever you point it at — only `00_setup.R`'s `ip_csv` / `surv_csv` settings change.

## Files

| File | Rows | Cols | Source | Use |
|---|---|---|---|---|
| `main_cases_67.csv`  | 67  | 90  | **Real** — 67 IP-led interview cases (cleared for publication) | Primary analysis |
| `other_cases_157.csv`| 157 | 120 | **Real** — 157 Future of Business Survey (FoBS) records | Pool with `main_*` for 224-row robustness check |
| `mock_cases_67.csv`  | 67  | 90  | Synthetic | Pipeline harness / collaborator onboarding |
| `mock_cases_157.csv` | 157 | 120 | Synthetic | Pipeline harness / collaborator onboarding |

The two 67-row files share an identical column layout (90 cols); the two 157-row files share theirs (120 cols — adds 30 `SURV_*` survey items). You can row-bind a 67-row file with its matching 157-row file into a pooled 224-row frame. Keep the `source` column so you can always split them again and run the with/without-survey robustness check flagged in the manuscript.

## Switching between real and mock

The pipeline reads whichever files are named in `00_setup.R`:

```r
PATHS <- list(
  ...
  ip_csv   = "mock_cases_67.csv",     # <- swap to "main_cases_67.csv"  for real analysis
  surv_csv = "mock_cases_157.csv"     # <- swap to "other_cases_157.csv" for real analysis
)
```

`00_setup.R` auto-detects mock vs real from the `^mock` filename prefix and sets `IS_MOCK`. When `IS_MOCK = TRUE`, all APA figures and table titles are watermarked `(illustrative; mock data)` so synthetic numbers can never be mistaken for results.

## Column groups (all four files)

- `case_id`, `source` — identifiers (`IP` for interview cases, `FoBS` for survey).
- Demographics — `gender`, `ethnic_group`, `education_level`, `business_location`, `income_level`, `business_type`. Populated in the 67-row files; `NA (online SME)` in the 157-row files (FoBS rows have no individual demographics).
- Raw items — 66 columns, 1–5 Likert, named `FACTOR_NN_stem` (e.g. `FIN_03_business_loan_access`).
- Factor scores `FACTOR_score` — item mean rescaled to 0–1 (BPRAC, FIN, ENVO, EPSY, BEASE).
- Calibrated sets `FACTOR_fz` — fuzzy membership in [0,1], direct method (logistic), anchors below.
- Outcome — `GROWTH_monthly_revenue_usd`, `GROWTH_growth_rate_selfrep`, `GROWTH_page_analytics_idx` (raw components), `GROWTH_score` (0–1), `GROWTH_fz` (calibrated), `GROWTH_binary` (≥0.5; for BRS).
- 157-row files only — `SURV_NN_subset_k`, 30 survey items across six subsets (`BEASE`, `FIN`, `BPRAC`, `EPSY`, `ENVO`, `DIGITAL_LEGAL`).

## Calibration anchors (illustrative — re-justify against your data before reporting)

| Set | full (0.95) | crossover (0.50) | non (0.05) |
|---|---|---|---|
| BEASE  | 0.80 | 0.50 | 0.20 |
| FIN    | 0.85 | 0.55 | 0.25 |
| BPRAC  | 0.82 | 0.50 | 0.18 |
| EPSY   | 0.88 | 0.60 | 0.30 |
| ENVO   | 0.78 | 0.48 | 0.20 |
| GROWTH | 0.80 | 0.45 | 0.15 |

Edit `ANCHORS` in `00_setup.R` to change them. Calibration anchors must be fixed *before* minimization, not tuned to a result. The substantive justification for each anchor used in the published analysis (and the membership-to-raw mapping $\text{raw} = 4m + 1$) is given in **Appendix A** of [`../TECHNICAL_ANNEX.md`](../TECHNICAL_ANNEX.md); the truth table and the pooled 224-record robustness analysis are in Appendices B and C.

## About the mock files

The mock CSVs were generated to test the pipeline before real data was available; **nothing produced from them is a finding**. Faithful to the paper: 67/157 case counts, the five factors, and the 67-case demographic marginals match Table 1 and Figures 2–3 exactly. Invented: all cell values (random draws with a mild artificial signal — high `BEASE` + `FIN` raises `GROWTH` — so the pipeline returns non-degenerate output), and the EPSY (22) and BEASE (15) item-count split (paper doesn't specify; 22 + 15 was chosen so the five factors sum to 66).

## About the real files

`main_cases_67.csv` contains the IP-led interview cases — Indigenous entrepreneurs in the Chittagong Hill Tracts (Chakma, Marma, Tripura) and elsewhere in Bangladesh. `other_cases_157.csv` contains the FoBS records used as the comparative pooled set. Both were cleared for publication.

**Two analytical cautions** (carried from the manuscript):
- **Small N.** With 67 real cases you are in the regime where the BRS paper's own simulations show QCA and BRS perform comparably; BRS here is an exploratory cross-check, not a rescue.
- **Synthetic survey rows are not in the real set.** When you pool the 224 rows, report results with and without the 157 FoBS rows.

## Quick start

```r
setwd("F:/EoT_Formal"); source("run_all.R")
```

fsQCA (R, package `QCA`): use the `*_fz` columns as conditions and `GROWTH_fz` as the outcome; build the truth table, set frequency and consistency cutoffs, minimize.

BRS (R package from Chiu & Xu): use discrete predictors and the binary outcome (`GROWTH_binary`). Their recommended discretization is overlapping incremental indicators (below 25th pct, below median, below 75th pct) built from raw items or scores — not single Likert values.
