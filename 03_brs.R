# =====================================================================
# 03_brs.R
# Bayesian Rule Set (Chiu & Xu) as a cross-check / large-N alternative.
# Discretizes the 0-1 factor scores into OVERLAPPING incremental binary
# features (the scheme the paper recommends), runs BRS with bootstrapping,
# aggregates a stable rule set, and produces the three BRS visuals.
#
# Requires the 'brs' package + a working Python env (see 00_setup.R).
# If brs is unavailable this script no-ops with a message.
#
# Small-N caveat: with 67 real cases you are in the regime where Chiu &
# Xu's simulations show QCA and BRS perform comparably. Treat BRS here as
# exploratory description, not a replacement for the fsQCA.
# =====================================================================
source("00_setup.R")
if (!HAVE_BRS) { message("[03_brs] 'brs' not installed; skipping."); quit(save = "no") }
set.seed(123)

## ---- 3.1 load ------------------------------------------------------
ip   <- read_csv(rdpath(PATHS$ip_csv),   show_col_types = FALSE)
surv <- read_csv(rdpath(PATHS$surv_csv), show_col_types = FALSE)

## ---- 3.2 discretize scores -> overlapping binary features ----------
# For a 0-1 score we build three overlapping indicators per factor:
#   <name>_lo      = score below the 1/3 quantile
#   <name>_lo_med  = score below the 2/3 quantile  (low OR medium)
#   <name>_hi      = score in the top tercile
# Overlapping cuts keep the feature matrix dense (Chiu & Xu's advice).
make_features <- function(df) {
  feat <- data.frame(row.names = df$case_id)
  for (cd in CONDITIONS) {
    s  <- df[[paste0(cd, "_score")]]
    q  <- quantile(s, c(1/3, 2/3), na.rm = TRUE)
    feat[[paste0(cd, "_lo")]]     <- as.integer(s <  q[1])
    feat[[paste0(cd, "_lo_med")]] <- as.integer(s <  q[2])
    feat[[paste0(cd, "_hi")]]     <- as.integer(s >= q[2])
  }
  feat
}

prep <- function(df) {
  X <- make_features(df)
  Y <- as.integer(df$GROWTH_binary)        # provided 0/1 outcome
  list(X = X, Y = Y)
}
ip_d     <- prep(ip)
pooled   <- bind_rows(ip, surv)
pooled_d <- prep(pooled)

## ---- 3.3 run BRS ---------------------------------------------------
# maxLen must be an integer literal (3L). bootstrap=T gives uncertainty.
run_brs <- function(d, reps = 100L) {
  brs::BRS(df = d$X, Y = d$Y, seed = 123, maxLen = 3L,
           bootstrap = TRUE, reps = reps)
}
fit_ip     <- run_brs(ip_d)
fit_pooled <- run_brs(pooled_d)

# aggregated, stable rule set (<=3 rules maximizing in-sample accuracy)
agg_ip     <- brs::agg_BRS(fit = fit_ip,     X = ip_d$X,     Y = ip_d$Y,     maxLen = 3)
agg_pooled <- brs::agg_BRS(fit = fit_pooled, X = pooled_d$X, Y = pooled_d$Y, maxLen = 3)

print(agg_ip); print(agg_pooled)
saveRDS(list(fit_ip = fit_ip, fit_pooled = fit_pooled,
             agg_ip = agg_ip, agg_pooled = agg_pooled,
             ip_d = ip_d, pooled_d = pooled_d), opath("brs_results.rds"))

## ---- 3.4 BRS visuals (bar / chord / t-SNE) -------------------------
# feature labels: 2 cols (raw colname, pretty label). Default to raw names.
fdf <- cbind(colnames(ip_d$X), colnames(ip_d$X))

# equivalence classes so 'not X=0' collapses to 'X=1' (binary features)
oppind <- list(colnames(ip_d$X))
oppmat <- matrix(c(0, 1), nrow = 1)

png(opath("brs_bar_ip67.png"), width = 1500, height = 1100, res = 150)
print(brs::plot_bar(df = ip_d$X, Y = ip_d$Y, fit = fit_ip,
        featureLabels = fdf, maxLen = 3, boot_rep = 100L,
        minProp = .05, topRules = 5, simplify = TRUE,
        oppmat = oppmat, oppind = oppind, and = " & ",
        plotBuffer = c(.25, 0, .4),
        titleSize = 10, rule_text_size = 10, number_size = 10))
dev.off()

# chord diagram of the aggregated rule set
fgs <- cbind(CONDITIONS, CONDITIONS)  # variable stems -> labels
png(opath("brs_chord_ip67.png"), width = 1100, height = 1100, res = 150)
brs::plot_chord(ruleSet = agg_ip, featureGroups = fgs,
                linkColors = RColorBrewer::brewer.pal(9, "Set3")[c(6, 5)],
                gridColors = "grey", textSize = 1, side_mar = 0, top_mar = 0)
dev.off()

# t-SNE of cases coloured by outcome, with rule-set coverage
set.seed(123)
png(opath("brs_tsne_ip67.png"), width = 1100, height = 1000, res = 150)
brs::plot_tsne(X = ip_d$X, Y = ip_d$Y, ruleSet = agg_ip,
               pointSize = 1.25, symb = c(20, 4),
               caseColors = RColorBrewer::brewer.pal(11, "RdYlGn")[c(2, 9)])
dev.off()

banner("03_brs done")
cat("BRS visuals written to", PATHS$out_dir, "\n")
