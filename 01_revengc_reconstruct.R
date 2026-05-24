# =====================================================================
# 01_revengc_reconstruct.R   ***ARCHIVAL / FOR POSTERITY***
# ---------------------------------------------------------------------
# This script documents HOW the 157-record comparison set was produced
# from aggregate (censored) Future of Business Survey marginals. You
# already have data/mock_cases_157.csv, so this is NOT part of run_all.R
# and does not need to be executed. Kept for reproducibility/provenance.
#
# Method: for each survey item you have a censored frequency table;
# revengc::cnbinom.pars() fits a negative binomial (mu, r) to it, and we
# draw synthetic respondents with rnbinom(). Output is SIMULATED data.
# To regenerate from real HDX marginals, replace `agg_tables` below.
# =====================================================================
source("00_setup.R")
set.seed(2026)

## ---- revengc availability (ARCHIVED from CRAN 2026-03-18) ----------
# revengc was archived from CRAN on 2026-03-18 (uncorrected check issues), so
# it cannot be installed with a plain install.packages(). We install the last
# archived source build. On Windows this requires Rtools (to build from source).
# If this fails, see the README for a dependency-free censored-NB alternative.
REVENGC_TARBALL <-
  "https://cran.r-project.org/src/contrib/Archive/revengc/revengc_1.0.4.tar.gz"
if (!requireNamespace("revengc", quietly = TRUE)) {
  message("[01] installing archived revengc from the CRAN archive ...")
  try(install.packages(REVENGC_TARBALL, repos = NULL, type = "source"),
      silent = TRUE)
}
if (!requireNamespace("revengc", quietly = TRUE))
  stop("revengc is unavailable. Install Rtools and re-run, or switch to the ",
       "self-contained censored-NB function described in the README.")
suppressMessages(library(revengc))

## ---- input: one censored frequency table per survey item ----------
# revengc format: 2 columns, col 1 = categories (censoring symbols
# allowed: "<=5","6-10",">20"), col 2 = counts. No row names.
make_example_table <- function()
  data.frame(category = c("<=1", "2-3", "4-5", "6-10", ">10"),
             freq     = c(140,   260,   190,   90,     40),
             stringsAsFactors = FALSE)

agg_tables <- list(
  SURV_BEASE_1 = make_example_table(), SURV_FIN_1 = make_example_table(),
  SURV_BPRAC_1 = make_example_table(), SURV_EPSY_1 = make_example_table(),
  SURV_ENVO_1  = make_example_table(), SURV_DIG_1  = make_example_table()
)
N_DRAW <- 157

## ---- fit NB params per item and draw samples ----------------------
reconstruct_item <- function(tab, n, clip = NULL) {
  pars  <- revengc::cnbinom.pars(censoredtable = tab)  # -> $Average, $Dispersion
  draws <- rnbinom(n, size = pars$Dispersion, mu = pars$Average)
  if (!is.null(clip)) draws <- pmin(pmax(draws, clip[1]), clip[2])
  list(mu = pars$Average, size = pars$Dispersion, draws = draws)
}
fits   <- lapply(agg_tables, reconstruct_item, n = N_DRAW)
params <- do.call(rbind, lapply(names(fits), function(k)
  data.frame(item = k, mu = fits[[k]]$mu, dispersion = fits[[k]]$size)))
print(params)
write_csv(params, opath("revengc_fitted_params.csv"))

recon <- as.data.frame(lapply(fits, function(f) f$draws))
recon$case_id <- sprintf("FoBS_%03d", seq_len(N_DRAW))
recon$source  <- "FoBS_reconstructed"
write_csv(recon, opath("revengc_reconstructed_raw.csv"))

banner("01_revengc (archival) done")
cat("Provenance only. run_all.R reads the existing data/mock_cases_157.csv.\n")
