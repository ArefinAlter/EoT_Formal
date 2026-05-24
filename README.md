# EoT_Formal — Indigenous Entrepreneurship: fsQCA + BRS pipeline improved

Analysis code for *The Formal-Informal Paradox of Indigenous Entrepreneurship in Bangladesh*. The pipeline calibrates condition scores into fuzzy sets, runs fuzzy-set Qualitative Comparative Analysis (fsQCA), runs a Bayesian Rule Set (BRS) cross-check, and produces the figures.

> **Technical Annex.** [`TECHNICAL_ANNEX.md`](TECHNICAL_ANNEX.md) supplements the manuscript with the formal material: the composite-index formulation, consistency/coverage measures, supplementary methodological notes, and Appendices A (calibration anchors), B (truth table), C (pooled 224-record robustness analysis) and D (variable-to-factor accounting). Equation and appendix labels match the main text.

> **Data.** `data/` contains **both real and mock** CSVs:
> - `main_cases_67.csv` (real, 67 IP-led interview cases — cleared for publication) and `other_cases_157.csv` (real, 157 FoBS records — cleared for publication) are the analysis inputs.
> - `mock_cases_67.csv` and `mock_cases_157.csv` are synthetic harnesses for collaborator onboarding; output produced from them is auto-watermarked *(illustrative; mock data)*.
>
> Swap which set the pipeline uses by editing `ip_csv` / `surv_csv` in `00_setup.R`. See [`data/DATA_README.md`](data/DATA_README.md) for the full dictionary.

## Repository layout
```
EoT_Formal/                 <- repo root = F:\EoT_Formal
  TECHNICAL_ANNEX.md        <- formal annex to the manuscript (equations, Appendices A-D)
  00_setup.R                <- packages, paths, calibration anchors, cutoffs  (edit here)
  01_revengc_reconstruct.R  <- ARCHIVAL: how the 157-record set was made (not run)
  02_fsqca.R                <- calibrate -> necessity -> truth table -> minimize
  03_brs.R                  <- Bayesian Rule Set + bar/chord/t-SNE (needs Python)
  04_visualize.R            <- APA descriptive + fsQCA figures (300 dpi)
  05_tables_apa.R           <- APA 7 tables (flextable) -> .docx + .html
  apa_helpers.R             <- shared APA theme + flextable styler
  run_all.R                 <- generates everything
  data/                     <- main_cases_67.csv, other_cases_157.csv (real, cleared)
                               mock_cases_67.csv, mock_cases_157.csv (synthetic)
                               DATA_README.md (data dictionary)
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

## Selecting which dataset to run

`00_setup.R` defaults to the mock files. To run on the real (publication-cleared) data, change:
```r
ip_csv   = "main_cases_67.csv"      # was: "mock_cases_67.csv"
surv_csv = "other_cases_157.csv"    # was: "mock_cases_157.csv"
```
The `IS_MOCK` flag is auto-detected from the `^mock` filename prefix, so figure/table watermarking turns off automatically when you switch to the real files. Set the `ANCHORS` to values you can justify against the real data; calibration anchors must be fixed *before* minimization, not tuned to a result. Then re-run `run_all.R`.

## Two analytical cautions (carried from the manuscript)
- **Small N.** With 67 real cases you are in the regime where the BRS paper's own simulations show QCA and BRS perform comparably; BRS here is an exploratory cross-check, not a rescue.
- **Synthetic survey rows.** The 157 reconstructed records are simulated. The `source` column lets you split them out; report pooled results with and without them.

## Data ethics
The four CSVs in `data/` are intentionally tracked: the two `mock_*` files are synthetic, and the `main_cases_67.csv` / `other_cases_157.csv` files contain real records that have been cleared for publication. `.gitignore` blocks `data/real_*.csv`, `data/*_confidential*.csv`, `data/*_raw*.csv`, and `data/*_pii*.csv` as safeguards against accidentally committing other confidential files later — review any new CSV before staging it.

## Reproducibility
Written against documented package APIs; not executed during authoring. A short note on environment setup (incl. the BRS/Python conda step) is in `00_setup.R`. Consider adding `renv` (`renv::init()`) to lock package versions before publishing.

Dependency note: `revengc` was archived from CRAN on 2026-03-18 and is used only by the archival reconstruction script, which installs it from the CRAN archive. For a fully self-contained repo (no archived dependency), inline a censored negative-binomial MLE in place of `cnbinom.pars()`; ask if you want that swap.

## License
This repository is dual-licensed:

- **Source code** (`*.R` files, `run_all.R`, helpers) — [MIT License](LICENSE).
- **Documentation, figures, tables, and publication-cleared data** (README files, [`TECHNICAL_ANNEX.md`](TECHNICAL_ANNEX.md), `output/`, `data/main_cases_67.csv`, `data/other_cases_157.csv`, `data/DATA_README.md`) — [Creative Commons Attribution 4.0 International (CC BY 4.0)](LICENSE-DOCS).

If you reuse the code, attribution is appreciated but not required. If you reuse the text, figures, tables, data, or the technical annex, please cite the repository and the manuscript.

## How to cite

If you use this repository or the technical annex, please cite both the manuscript and the code:

> ArefinAlter (2026). *The Formal–Informal Paradox of Indigenous Entrepreneurship in Bangladesh* — Technical Annex and analysis code (EoT_Formal). https://github.com/ArefinAlter/EoT_Formal
