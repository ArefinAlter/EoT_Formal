# EoT_Formal — Indigenous Entrepreneurship: fsQCA + BRS pipeline

Analysis code for *The Formal-Informal Paradox of Indigenous Entrepreneurship in Bangladesh*. The pipeline calibrates condition scores into fuzzy sets, runs fuzzy-set Qualitative Comparative Analysis (fsQCA), runs a Bayesian Rule Set (BRS) cross-check, and produces the figures.

> **Status: runs on mock data.** The CSVs in `data/` are synthetic, generated only to test this pipeline. Their values are random (with a mild artificial signal so the code returns non-degenerate output). **Nothing produced from them is a finding.** See `data/MOCK_DATA_README.md`.

## Repository layout
```
EoT_Formal/                 <- repo root = F:\EoT_Formal
  00_setup.R                <- packages, paths, calibration anchors, cutoffs  (edit here)
  01_revengc_reconstruct.R  <- ARCHIVAL: how the 157-record set was made (not run)
  02_fsqca.R                <- calibrate -> necessity -> truth table -> minimize
  03_brs.R                  <- Bayesian Rule Set + bar/chord/t-SNE (needs Python)
  04_visualize.R            <- APA descriptive + fsQCA figures (300 dpi)
  05_tables_apa.R           <- APA 7 tables (flextable) -> .docx + .html
  apa_helpers.R             <- shared APA theme + flextable styler
  run_all.R                 <- generates everything
  data/                     <- mock_cases_67.csv, mock_cases_157.csv
  output/                   <- generated tables and figures
    tables_apa/             <- APA tables (.docx/.html) + ALL_TABLES_apa.docx
    APA_figure_captions.txt <- ready-to-paste figure captions
```

## Quick start
```r
# in R / RStudio
setwd("F:/EoT_Formal")
source("run_all.R")          # 00 -> 02 -> 04 (-> 03 if 'brs' installed)
```
Install packages first (see `00_setup.R`). BRS is optional and is skipped automatically if not installed.

## Publication-ready output (APA 7)
`05_tables_apa.R` and the APA-themed `04_visualize.R` produce submission-grade exhibits: APA tables (number, italic title, horizontal rules only, Note line) exported to `.docx` and `.html` via `flextable`, and 300-dpi figures with a sans-serif APA theme and greyscale-safe fills. Figure captions are written to `output/APA_figure_captions.txt` for pasting into the manuscript. Caveats: (a) APA 7 has no formal spec for fsQCA configurational tables, so the content follows QCA reporting conventions (Schneider & Wagemann) within APA's general table rules; (b) the three BRS plots are produced by the `brs` package and keep that package's styling. On mock data, all titles are auto-watermarked "(illustrative; mock data)".

## Methods → packages
- **fsQCA**: `QCA` (calibrate, superSubset, pof, truthTable, minimize).
- **BRS**: `brs` (github.com/albert-chiu/brs), Python-backed via `reticulate`.
- **Reconstruction (archival)**: `revengc` (cnbinom.pars + rnbinom). **`revengc` was archived from CRAN on 2026-03-18**, so `01_revengc_reconstruct.R` installs the last archived source build itself (needs Rtools on Windows). The main pipeline does not depend on it. If it will not build, replace `cnbinom.pars()` with a self-contained censored negative-binomial MLE (a ~15-line function), or, if you have a donor microdata sample rather than margins only, use `simPop` (IPU / simulated annealing; Templ et al., 2017) instead.

## Switching to real data
1. Put your real files in `data/` and point `ip_csv` / `surv_csv` in `00_setup.R` at them. Keep the mock column layout: a `*_score` column per condition plus `GROWTH_score` and `GROWTH_binary`.
2. Set the `ANCHORS` in `00_setup.R` to values you can justify. Calibration anchors must be fixed *before* minimization, not tuned to a result.
3. Re-run `run_all.R`.

## Two analytical cautions (carried from the manuscript)
- **Small N.** With 67 real cases you are in the regime where the BRS paper's own simulations show QCA and BRS perform comparably; BRS here is an exploratory cross-check, not a rescue.
- **Synthetic survey rows.** The 157 reconstructed records are simulated. The `source` column lets you split them out; report pooled results with and without them.

## Data ethics
The mock data is safe to publish. **Do not commit real case-level interview data** about a small, identifiable Indigenous population to a public repository without consent and anonymization. `.gitignore` already excludes `data/real_*.csv` and `data/*_confidential*.csv`.

## Reproducibility
Written against documented package APIs; not executed during authoring. A short note on environment setup (incl. the BRS/Python conda step) is in `00_setup.R`. Consider adding `renv` (`renv::init()`) to lock package versions before publishing.

Dependency note: `revengc` was archived from CRAN on 2026-03-18 and is used only by the archival reconstruction script, which installs it from the CRAN archive. For a fully self-contained repo (no archived dependency), inline a censored negative-binomial MLE in place of `cnbinom.pars()`; ask if you want that swap.

## License
No license is included by default. Add one (e.g. MIT for code; CC-BY for text/figures) before making the repo public, or state "all rights reserved".
