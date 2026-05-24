# =====================================================================
# 02_fsqca.R
# Calibration -> necessity -> truth table -> minimization
# (conservative / parsimonious / intermediate) -> parameters of fit.
#
# Reads the *_score columns from the case CSVs and calibrates them with
# QCA::calibrate using the anchors in 00_setup.R. You can analyse the
# IP-only sample (67) or the pooled sample (67 + 157). Both are produced.
# =====================================================================
source("00_setup.R")

# Robust extractor: tidy a minimize() solution's parameters of fit into
# term / consistency / PRI / raw_coverage / unique_coverage. Column names
# vary slightly across QCA versions, so we pick defensively.
extract_pof <- function(sol) {
  ic <- tryCatch(sol$IC$incl.cov, error = function(e) NULL)
  if (is.null(ic)) ic <- tryCatch(sol$IC$sol.incl.cov, error = function(e) NULL)
  if (is.null(ic)) return(NULL)
  df <- as.data.frame(ic); nm <- names(df)
  pick <- function(cands) { i <- which(tolower(nm) %in% tolower(cands)); if (length(i)) nm[i[1]] else NA }
  grab <- function(cands) { p <- pick(cands); if (is.na(p)) NA else df[[p]] }
  data.frame(
    term            = rownames(df),
    consistency     = round(as.numeric(grab(c("inclS","incl","consistency"))), APA$dec_fit),
    PRI             = round(as.numeric(grab(c("PRI"))),                         APA$dec_fit),
    raw_coverage    = round(as.numeric(grab(c("covS","cov.r","raw"))),          APA$dec_fit),
    unique_coverage = round(as.numeric(grab(c("covU","unique"))),               APA$dec_fit),
    row.names = NULL, check.names = FALSE)
}

## ---- 2.1 load and assemble ----------------------------------------
ip   <- read_csv(rdpath(PATHS$ip_csv),   show_col_types = FALSE)
surv <- read_csv(rdpath(PATHS$surv_csv), show_col_types = FALSE)

src_suffix <- if (USE_PROVIDED_FZ) "_fz" else "_score"
need <- paste0(c(CONDITIONS, OUTCOME), src_suffix)
stopifnot(all(need %in% names(ip)), all(need %in% names(surv)))

ip_in   <- ip   |> select(case_id, source, all_of(need))
surv_in <- surv |> select(case_id, source, all_of(need))
pooled  <- bind_rows(ip_in, surv_in)

## ---- 2.2 build fuzzy sets -----------------------------------------
# Default (USE_PROVIDED_FZ = TRUE): use the already-calibrated *_fz columns,
# honoring your bespoke GROWTH definition and equal-weight scoring. If FALSE,
# recalibrate the *_score columns with ANCHORS. Either way, any exact-0.5
# (ambiguous crossover) membership is nudged to 0.501 so the truth table is
# well defined (this affects ENVO here: 4 cases in the 67 set, more in 157).
build_sets <- function(df) {
  out <- df["case_id"]
  for (v in c(CONDITIONS, OUTCOME)) {
    if (USE_PROVIDED_FZ) {
      m <- df[[paste0(v, "_fz")]]
    } else {
      thr <- ANCHORS[[v]]
      m <- QCA::calibrate(df[[paste0(v, "_score")]], type = "fuzzy",
                          thresholds = c(e = thr["e"], c = thr["c"], i = thr["i"]))
    }
    m[m == 0.5] <- 0.501
    out[[v]] <- m
  }
  as.data.frame(out)
}
cal_ip     <- build_sets(ip_in)
cal_pooled <- build_sets(pooled)
write_csv(cal_ip,     opath("calibrated_ip67.csv"))
write_csv(cal_pooled, opath("calibrated_pooled224.csv"))

## ---- 2.3 one reusable analysis routine -----------------------------
run_fsqca <- function(cal, tag) {
  banner(paste("fsQCA:", tag))
  rownames(cal) <- cal$case_id
  dat <- cal[, c(CONDITIONS, OUTCOME)]

  # ---- necessity (single conditions, presence and absence) ----
  nec <- QCA::superSubset(dat, outcome = OUTCOME,
                          conditions = CONDITIONS,
                          relation = "necessity",
                          incl.cut = QCA_SET$nec.incl,
                          cov.cut  = QCA_SET$nec.cov)
  save_txt(nec, paste0("necessity_", tag, ".txt"))

  # full necessity parameters of fit for every condition (and ~negation)
  # necessity parameters of fit for each condition (presence only)
  nec_tab <- do.call(rbind, lapply(CONDITIONS, function(cd) {
    p <- QCA::pof(dat[[cd]], dat[[OUTCOME]], relation = "necessity")$incl.cov
    data.frame(condition = cd, p)
  }))
  write_csv(nec_tab, opath(paste0("necessity_pof_", tag, ".csv")))

  # ---- truth table ----
  tt <- QCA::truthTable(dat, outcome = OUTCOME, conditions = CONDITIONS,
                        incl.cut = QCA_SET$incl.cut, pri.cut = QCA_SET$pri.cut,
                        n.cut = QCA_SET$n.cut, show.cases = TRUE,
                        sort.by = c("OUT", "n"), complete = FALSE)
  save_txt(tt, paste0("truthtable_", tag, ".txt"))
  write_csv(as.data.frame(tt$tt), opath(paste0("truthtable_", tag, ".csv")))

  # ---- minimization: conservative / parsimonious / intermediate ----
  sol_c <- QCA::minimize(tt, details = TRUE, show.cases = TRUE)
  sol_p <- QCA::minimize(tt, include = "?", details = TRUE)
  sol_i <- QCA::minimize(
    tt, include = "?", details = TRUE,
    dir.exp = setNames(rep(1, length(CONDITIONS)), CONDITIONS)) # expect presence
  save_txt(sol_c, paste0("solution_conservative_", tag, ".txt"))
  save_txt(sol_p, paste0("solution_parsimonious_", tag, ".txt"))
  save_txt(sol_i, paste0("solution_intermediate_", tag, ".txt"))

  # parameters of fit for ALL three solutions -> CSV (consumed by 05_tables_apa.R)
  pofs <- list(conservative = extract_pof(sol_c),
               parsimonious = extract_pof(sol_p),
               intermediate = extract_pof(sol_i))
  for (nm in names(pofs)) if (!is.null(pofs[[nm]]))
    write_csv(pofs[[nm]], opath(paste0("solution_", nm, "_pof_", tag, ".csv")))
  list(tt = tt, conservative = sol_c, parsimonious = sol_p,
       intermediate = sol_i, necessity = nec, calibrated = cal)
}

res_ip     <- run_fsqca(cal_ip,     "ip67")
res_pooled <- run_fsqca(cal_pooled, "pooled224")

saveRDS(list(ip = res_ip, pooled = res_pooled), opath("fsqca_results.rds"))
banner("02_fsqca done")
cat("Outputs in", PATHS$out_dir, ": calibrated_*, necessity_*, truthtable_*, solution_*\n")
