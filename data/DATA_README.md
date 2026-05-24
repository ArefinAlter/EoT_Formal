# Mock datasets — README and data dictionary

**These two CSVs are synthetic. The values are random. They are a harness for testing your fsQCA / BRS pipeline, not data and not results.** Replace every column with your real items and values before any analysis you intend to report.

## Files
- `mock_cases_67.csv` — 67 rows, standing in for the IP-led interview cases.
- `mock_cases_157.csv` — 157 rows, standing in for the reverse-engineered Future of Business Survey records.

The two files share an identical block of analysis columns (the five factor scores, their calibrated sets, and the GROWTH columns), so you can row-bind them into a pooled 224-row frame if you want to reproduce the paper's pooled design. Keep the `source` column so you can always split them again and run the with/without-synthetic robustness check I flagged in the manuscript.

## What is faithful to your paper vs. invented
Faithful (taken from the paper):
- 67 / 157 case counts; the 5 factors and the item counts you specified (BPRAC 6, FIN 14, ENVO 9).
- The 67-case demographic marginals match Table 1 and Figures 2–3 exactly: gender (49/17/1), ethnic group (45/13/7/2), education (3/12/9/43), location (21/9/13/17/5/2), business type (44/5/15/3).

Invented (because the paper does not specify them) — **replace these**:
- The item names for all 66 variables, and especially the **EPSY (22) and BEASE (15)** counts, which the paper never gives. 22 + 15 = 37 was chosen only so the five factors sum to 66; your real split may differ.
- All cell values. They are random draws, not observations.
- The income marginal: the paper's Table 1 income counts sum to 64, not 67, so the three missing cases were assigned to "Middle" (12 / 37 / 18). Fix to your real counts.
- The 30 survey items in the 157 file are grouped into **six** subsets (the paper is internally inconsistent on five vs six — see the manuscript flag); the sixth is labelled `DIGITAL_LEGAL`.

## Embedded artificial signal (so the pipeline returns something)
Values were generated so that high membership in **BEASE and FIN** raises GROWTH, while EPSY/BPRAC/ENVO matter much less. This mirrors your paper's narrative and your case examples (Dhaka EdTech: high formal access → growth; remote Bandarban couple: high FIN but low BEASE/ENVO → marginal growth), which is built in via location/education/income biases. **This signal is fabricated.** Any rule or solution you recover from these files describes the noise I generated, not the world.

## Column groups (both files)
- `case_id`, `source` — identifiers.
- Demographics (`gender`, `ethnic_group`, `education_level`, `business_location`, `income_level`, `business_type`) — real values in the 67 file; `NA (online SME)` in the 157 file.
- Raw items, 1–5 Likert, named `FACTOR_NN_stem` (e.g. `FIN_03_business_loan_access`). 66 of them in the 67 file.
- Factor scores `FACTOR_score` — item mean rescaled to 0–1 (BPRAC, FIN, ENVO, EPSY, BEASE).
- Calibrated sets `FACTOR_fz` — fuzzy membership in [0,1], direct method (logistic), anchors below.
- Outcome: `GROWTH_monthly_revenue_usd`, `GROWTH_growth_rate_selfrep`, `GROWTH_page_analytics_idx` (raw components), `GROWTH_score` (0–1), `GROWTH_fz` (calibrated), `GROWTH_binary` (≥0.5; for BRS).
- 157 file only: `SURV_NN_subset_k` — 30 survey items across six subsets.

## Calibration anchors used (illustrative — match to your own before reporting)
| Set | full (0.95) | crossover (0.50) | non (0.05) |
|---|---|---|---|
| BEASE | 0.80 | 0.50 | 0.20 |
| FIN | 0.85 | 0.55 | 0.25 |
| BPRAC | 0.82 | 0.50 | 0.18 |
| EPSY | 0.88 | 0.60 | 0.30 |
| ENVO | 0.78 | 0.48 | 0.20 |
| GROWTH | 0.80 | 0.45 | 0.15 |

These are the same illustrative anchors as the mock worksheet, applied to the 0–1 factor scores.

## Quick start
fsQCA (R, package `QCA`): use the `*_fz` columns as conditions and `GROWTH_fz` as the outcome; build the truth table, set frequency and consistency cutoffs, minimize.

BRS (R package from Chiu & Xu): use discrete predictors and a binary outcome (`GROWTH_binary`). Their recommended discretization is overlapping incremental indicators (below 25th pct, below median, below 75th pct) built from the raw items or scores — not the single Likert values.

Reminder, because it matters: with 67 real cases you are in the small-N regime where the paper's own simulations show QCA and BRS perform comparably, so BRS here is an exploratory cross-check, not a rescue. And the 157 reconstructed rows are simulated; report any pooled result with and without them.
