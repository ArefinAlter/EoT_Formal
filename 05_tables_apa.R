# =====================================================================
# 05_tables_apa.R  --  publication-ready (APA 7) tables
# Reads the CSVs written by 02_fsqca.R and the case data, formats them as
# APA flextables, and exports each to .docx and .html plus one combined
# Word file (output/tables_apa/). Run 02_fsqca.R first.
#
# Tables produced (for the IP-only sample; pooled versions also written):
#   1  Sample description (education, location, income, type, gender, ethnicity)
#   2  Analysis of necessary conditions
#   3  Truth table (observed configurations)
#   4  Sufficiency solutions (conservative / parsimonious / intermediate)
# ======================================================================
source("00_setup.R")
source("apa_helpers.R")
tdir <- file.path(PATHS$out_dir, "tables_apa")
dir.create(tdir, showWarnings = FALSE, recursive = TRUE)
tpath <- function(f) file.path(tdir, f)

ip <- readr::read_csv(rdpath(PATHS$ip_csv), show_col_types = FALSE)

export_ft <- function(ft, stem) {
  flextable::save_as_docx(ft, path = tpath(paste0(stem, ".docx")))
  flextable::save_as_html(ft, path = tpath(paste0(stem, ".html")))
}

doc <- apa_doc_new()

## ---- Table 1: sample description -----------------------------------
desc_block <- function(df, var, label) {
  df |>
    dplyr::count(.data[[var]]) |>
    dplyr::mutate(Characteristic = label,
                  Level = as.character(.data[[var]]),
                  n = n,
                  `%` = round(100 * n / sum(n), APA$dec_desc)) |>
    dplyr::select(Characteristic, Level, n, `%`)
}
t1 <- dplyr::bind_rows(
  desc_block(ip, "education_level",   "Education"),
  desc_block(ip, "business_location", "Business location"),
  desc_block(ip, "income_level",      "Income level"),
  desc_block(ip, "business_type",     "Business type"),
  desc_block(ip, "gender",            "Gender"),
  desc_block(ip, "ethnic_group",      "Ethnic group")
)
ft1 <- apa_ft(as.data.frame(t1), 1,
              "Sample characteristics of Indigenous business case studies (N = 67)",
              note = "Percentages are within each characteristic.",
              dec = APA$dec_desc)
export_ft(ft1, "table1_sample"); doc <- apa_doc_add(doc, ft1)

## ---- Table 2: necessity --------------------------------------------
nec_csv <- opath("necessity_pof_ip67.csv")
if (file.exists(nec_csv)) {
  nec <- readr::read_csv(nec_csv, show_col_types = FALSE)
  names(nec)[names(nec) == "condition"] <- "Condition"
  # prettify common necessity column names across QCA versions; keep any others
  ren <- c(inclN = "Consistency", incl = "Consistency",
           covN = "Coverage",    cov.r = "Coverage", RoN = "Relevance")
  for (o in names(ren)) names(nec)[names(nec) == o] <- ren[[o]]
  keep <- c("Condition", setdiff(names(nec), "Condition"))   # keep all fit columns
  ft2 <- apa_ft(as.data.frame(nec[keep]), 2,
                "Analysis of necessary conditions for GROWTH",
                note = paste("Consistency >= .90 is the conventional threshold for",
                             "necessity. RoN = relevance of necessity."))
  export_ft(ft2, "table2_necessity"); doc <- apa_doc_add(doc, ft2)
} else message("[05] necessity CSV not found; run 02_fsqca.R")

## ---- Table 3: truth table ------------------------------------------
tt_csv <- opath("truthtable_ip67.csv")
if (file.exists(tt_csv)) {
  tt <- readr::read_csv(tt_csv, show_col_types = FALSE)
  # keep the conventional truth-table columns if present
  cond_cols <- intersect(CONDITIONS, names(tt))
  extra <- intersect(c("OUT", "n", "incl", "PRI"), names(tt))
  tt2 <- tt[, c(cond_cols, extra)]
  if ("n" %in% names(tt2)) tt2 <- tt2[tt2$n > 0, ]   # observed configurations only
  names(tt2)[names(tt2) == "OUT"]  <- "Outcome"
  names(tt2)[names(tt2) == "incl"] <- "Consistency"
  ft3 <- apa_ft(as.data.frame(tt2), 3,
                "Truth table of observed configurations for GROWTH",
                note = paste("1 = condition present, 0 = absent.",
                             "Outcome coded using incl.cut =", QCA_SET$incl.cut,
                             "and PRI cut =", QCA_SET$pri.cut, "."),
                dec = APA$dec_fit)
  export_ft(ft3, "table3_truthtable"); doc <- apa_doc_add(doc, ft3)
} else message("[05] truth table CSV not found; run 02_fsqca.R")

## ---- Table 4: sufficiency solutions --------------------------------
sol_files <- c(conservative = "solution_conservative_pof_ip67.csv",
               parsimonious = "solution_parsimonious_pof_ip67.csv",
               intermediate = "solution_intermediate_pof_ip67.csv")
sol_list <- list()
for (nm in names(sol_files)) {
  f <- opath(sol_files[[nm]])
  if (file.exists(f)) {
    d <- readr::read_csv(f, show_col_types = FALSE)
    d$Solution <- tools::toTitleCase(nm)
    sol_list[[nm]] <- d
  }
}
if (length(sol_list)) {
  sol <- dplyr::bind_rows(sol_list) |>
    dplyr::rename(Term = term, Consistency = consistency,
                  `Raw coverage` = raw_coverage,
                  `Unique coverage` = unique_coverage) |>
    dplyr::select(Solution, Term, Consistency, PRI,
                  `Raw coverage`, `Unique coverage`)
  ft4 <- apa_ft(as.data.frame(sol), 4,
                "Sufficiency solutions for GROWTH",
                note = paste("Conditions within a term are joined by '*' (logical AND);",
                             "'~' denotes the absence of a condition.",
                             "Unique coverage <= raw coverage by construction."),
                dec = APA$dec_fit)
  export_ft(ft4, "table4_solutions"); doc <- apa_doc_add(doc, ft4)
} else message("[05] solution CSVs not found; run 02_fsqca.R")

## ---- combined Word file --------------------------------------------
apa_doc_save(doc, file.path("tables_apa", "ALL_TABLES_apa.docx"))

banner("05_tables_apa done")
cat("APA tables (.docx + .html) in", tdir, "\n")
if (IS_MOCK) cat("NOTE: titles are watermarked '(illustrative; mock data)'.\n")
