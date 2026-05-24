# =====================================================================
# 00_setup.R  --  packages, paths, shared helpers
# Project: EoT_Formal  (Formal-Informal Paradox of Indigenous
#          Entrepreneurship in Bangladesh)
# Pipeline: [revengc -- archival] -> fsQCA -> BRS, with visualization
#
# Repo layout (scripts run from the repo root):
#   EoT_Formal/
#     00_setup.R 02_fsqca.R 03_brs.R 04_visualize.R run_all.R
#     01_revengc_reconstruct.R        <- archival, NOT in run_all
#     data/    mock_cases_67.csv  mock_cases_157.csv
#     output/  (generated)
#
# NOTE: written against verified package APIs (QCA, revengc on CRAN;
# brs from github.com/albert-chiu/brs). Not executed while authoring;
# expect minor environment tweaks, especially the BRS/Python step.
# =====================================================================

## ---- 0.1 base directory -------------------------------------------
# Your machine. Falls back to the current working directory if the
# hard-coded path is not found (e.g. on a collaborator's computer).
BASE_DIR <- "F:/EoT_Formal"          # forward slashes in R
if (!dir.exists(BASE_DIR)) BASE_DIR <- getwd()

## ---- 0.2 CRAN packages --------------------------------------------
cran_pkgs <- c(
  "QCA",          # fsQCA: calibrate, truthTable, minimize, pof, superSubset
  "dplyr", "tidyr", "readr", "stringr", "tibble",
  "ggplot2", "scales", "RColorBrewer", "reshape2",
  "flextable", "officer",   # APA tables -> Word/HTML
  "reticulate"    # required by brs (Python backend)
)
# NOTE: 'revengc' was ARCHIVED from CRAN on 2026-03-18, so it is intentionally
# NOT in the vector above (a plain install.packages would fail). It is only
# needed by the archival script 01_revengc_reconstruct.R, which installs it
# from the CRAN archive itself. The main pipeline does not depend on it.
to_install <- cran_pkgs[!cran_pkgs %in% rownames(installed.packages())]
if (length(to_install))
  install.packages(to_install, repos = "https://cloud.r-project.org")
invisible(lapply(cran_pkgs, require, character.only = TRUE))

## ---- 0.3 BRS package (GitHub + Python) ----------------------------
# Install once:
#   if (!requireNamespace("devtools", quietly = TRUE)) install.packages("devtools")
#   devtools::install_github("albert-chiu/brs")
# BRS runs Python via reticulate; set up a conda env ONCE before library(brs).
# On Windows with miniforge, adjust paths accordingly, e.g.:
#   reticulate::conda_install(
#     envname  = "BRS_conda",
#     packages = c("numpy","pandas","scikit-learn","scipy"))
#   reticulate::use_condaenv("BRS_conda")
HAVE_BRS <- requireNamespace("brs", quietly = TRUE)
if (HAVE_BRS) suppressMessages(library(brs)) else
  message("[setup] 'brs' not installed -> 03_brs.R will be skipped.")

## ---- 0.4 paths -----------------------------------------------------
# Swap the two filenames for your REAL data when ready; nothing else changes.
PATHS <- list(
  data_dir = file.path(BASE_DIR, "data"),
  out_dir  = file.path(BASE_DIR, "output"),
  ip_csv   = "mock_cases_67.csv",     # <- replace with real 67-case file
  surv_csv = "mock_cases_157.csv"     # <- replace with real reconstructed file
)
dir.create(PATHS$out_dir, showWarnings = FALSE, recursive = TRUE)
rdpath <- function(f) file.path(PATHS$data_dir, f)
opath  <- function(f) file.path(PATHS$out_dir, f)

# Mock-data flag: when TRUE, APA table/figure titles are watermarked so
# synthetic numbers can never be mistaken for results. Auto-detected from
# the filename; set manually to FALSE once you use real data.
IS_MOCK <- grepl("^mock", PATHS$ip_csv)

# APA formatting options
APA <- list(
  font     = "Times New Roman",  # APA 7 allows TNR 12, Calibri 11, Arial 11
  fig_font = "sans",             # figures: sans-serif (e.g., Arial/Calibri)
  fig_dpi  = 300,
  dec_fit  = 3,                  # decimals for consistency/coverage/PRI
  dec_desc = 2                   # decimals for descriptive proportions
)

## ---- 0.5 analysis settings ----------------------------------------
CONDITIONS <- c("BEASE", "FIN", "BPRAC", "EPSY", "ENVO")
OUTCOME    <- "GROWTH"

# Calibration anchors (full-in i, crossover c, full-out e) on the 0-1
# *_score columns. MATCH THESE TO YOUR OWN THEORY/DATA before reporting.
ANCHORS <- list(
  BEASE  = c(i = 0.80, c = 0.50, e = 0.20),
  FIN    = c(i = 0.85, c = 0.55, e = 0.25),
  BPRAC  = c(i = 0.82, c = 0.50, e = 0.18),
  EPSY   = c(i = 0.88, c = 0.60, e = 0.30),
  ENVO   = c(i = 0.78, c = 0.48, e = 0.20),
  GROWTH = c(i = 0.80, c = 0.45, e = 0.15)
)

# fsQCA cutoffs (small-N friendly). Tune for your data.
QCA_SET <- list(
  incl.cut = 0.80, pri.cut = 0.65, n.cut = 1,
  nec.incl = 0.90, nec.cov = 0.50
)

## ---- 0.6 helpers ---------------------------------------------------
save_txt <- function(x, file) {
  writeLines(capture.output(print(x)), opath(file)); invisible(x)
}
banner <- function(msg) cat("\n========== ", msg, " ==========\n", sep = "")

cat("[setup] BASE_DIR =", BASE_DIR,
    "\n[setup] conditions:", paste(CONDITIONS, collapse = ", "),
    "| outcome:", OUTCOME, "\n")
