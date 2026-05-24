# =====================================================================
# run_all.R  --  generate everything
# Usage (R console or RStudio):
#   setwd("F:/EoT_Formal")
#   source("run_all.R")
#
# Note: 01_revengc_reconstruct.R is archival and intentionally NOT run
# here -- the 157-record file already exists in data/.
# =====================================================================
message(">>> 00 setup");     source("00_setup.R")
message(">>> 02 fsQCA");      source("02_fsqca.R")
message(">>> 05 APA tables"); source("05_tables_apa.R")
message(">>> 04 visualize"); source("04_visualize.R")   # XY plots need 02 first
if (HAVE_BRS) { message(">>> 03 BRS"); source("03_brs.R") } else
  message(">>> 03 BRS skipped (install 'brs' to enable)")
message(">>> done. Outputs in ", PATHS$out_dir, "/")
