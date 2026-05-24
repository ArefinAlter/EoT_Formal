# =====================================================================
# 04_visualize.R  --  APA-styled descriptive + fsQCA figures
# Figures use theme_apa_gg(); each is exported at 300 dpi and its APA
# caption (Figure N, title, Note) is appended to output/APA_figure_captions.txt
# so you can paste captions straight into the manuscript.
#   Fig 1 gender composition      Fig 2 ethnic-group composition
#   Fig 3 factor-score distributions   Fig 4 factor correlation heatmap
#   Fig 5 sufficiency XY plot     Fig 6 necessity XY plot
# (BRS bar/chord/t-SNE are produced in 03_brs.R via the brs package.)
# =====================================================================
source("00_setup.R")
source("apa_helpers.R")
theme_set(theme_apa_gg())
ACC <- "#2b2b2b"; HIL <- "#6e6e6e"; GREY <- "#9e9e9e"
if (file.exists(opath("APA_figure_captions.txt"))) file.remove(opath("APA_figure_captions.txt"))

ip   <- read_csv(rdpath(PATHS$ip_csv),   show_col_types = FALSE)
surv <- read_csv(rdpath(PATHS$surv_csv), show_col_types = FALSE)

## ---- Fig 1: gender --------------------------------------------------
g_gender <- ip |> count(gender) |>
  ggplot(aes(reorder(gender, n), n, fill = gender)) +
  geom_col(width = .65, show.legend = FALSE, colour = "black", linewidth = .2) +
  geom_text(aes(label = n), hjust = -0.25, size = 3.4) +
  coord_flip() +
  scale_fill_manual(values = APA_GREYS) +
  scale_y_continuous(expand = expansion(mult = c(0, .12))) +
  labs(x = NULL, y = "Number of participants (N = 67)")
save_apa_fig(g_gender, "fig1_gender.png", 1,
             "Gender composition of the case-study sample.",
             width = 6, height = 3)

## ---- Fig 2: ethnic group -------------------------------------------
g_eth <- ip |> count(ethnic_group) |>
  ggplot(aes(reorder(ethnic_group, n), n, fill = ethnic_group)) +
  geom_col(width = .65, show.legend = FALSE, colour = "black", linewidth = .2) +
  geom_text(aes(label = n), hjust = -0.25, size = 3.4) +
  coord_flip() +
  scale_fill_manual(values = APA_GREYS) +
  scale_y_continuous(expand = expansion(mult = c(0, .12))) +
  labs(x = NULL, y = "Number of participants (N = 67)")
save_apa_fig(g_eth, "fig2_ethnic.png", 2,
             "Ethnic-group composition of the case-study sample.",
             width = 6, height = 3)

## ---- Fig 3: factor-score distributions -----------------------------
sc <- ip |> select(all_of(paste0(CONDITIONS, "_score"))) |>
  pivot_longer(everything(), names_to = "factor", values_to = "score") |>
  mutate(factor = sub("_score", "", factor))
g_dist <- ggplot(sc, aes(score, factor)) +
  geom_violin(alpha = .5, scale = "width", fill = GREY, colour = "black", linewidth = .2) +
  geom_jitter(height = .12, size = .6, alpha = .5) +
  labs(x = "Factor score (0\u20131)", y = NULL)
save_apa_fig(g_dist, "fig3_factor_dist.png", 3,
             "Distribution of condition scores across cases.",
             width = 6.5, height = 4)

## ---- Fig 4: factor correlation heatmap -----------------------------
cmat <- cor(ip[paste0(CONDITIONS, "_score")], use = "pairwise.complete.obs")
cm <- reshape2::melt(cmat)
g_cor <- ggplot(cm, aes(Var1, Var2, fill = value)) +
  geom_tile(colour = "white") +
  geom_text(aes(label = sprintf("%.2f", value)), size = 3) +
  scale_fill_gradient2(low = "white", mid = "#bdbdbd", high = "#2b2b2b",
                       midpoint = 0, limits = c(-1, 1)) +
  labs(x = NULL, y = NULL, fill = "r") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
save_apa_fig(g_cor, "fig4_factor_corr.png", 4,
             "Pairwise correlations among condition scores (case-study instrument).",
             note = "Cells show Pearson r.",
             width = 5.5, height = 4.5)

## ---- Fig 5 & 6: fsQCA XY plots -------------------------------------
if (file.exists(opath("fsqca_results.rds"))) {
  res <- readRDS(opath("fsqca_results.rds"))
  cal <- res$ip$calibrated
  out <- cal[[OUTCOME]]

  # Fig 5: sufficiency of the BEASE*FIN conjunction (X <= Y => consistent)
  suf  <- pmin(cal$BEASE, cal$FIN)
  cons <- sum(pmin(suf, out)) / sum(suf)
  g_xy <- ggplot(data.frame(x = suf, y = out), aes(x, y)) +
    geom_abline(slope = 1, intercept = 0, linetype = 2, colour = GREY) +
    geom_point(size = 2, alpha = .7) +
    lims(x = c(0, 1), y = c(0, 1)) +
    labs(x = "Membership in BEASE * FIN", y = "Membership in GROWTH")
  save_apa_fig(g_xy, "fig5_qca_xy.png", 5,
               "Sufficiency XY plot for the BEASE * FIN path.",
               note = sprintf("Consistency = %.2f. Points on or below the diagonal are consistent with sufficiency.", cons),
               width = 5, height = 5)

  # Fig 6: necessity of FIN (X >= Y => consistent)
  neccon <- sum(pmin(cal$FIN, out)) / sum(out)
  g_nec <- ggplot(data.frame(x = cal$FIN, y = out), aes(x, y)) +
    geom_abline(slope = 1, intercept = 0, linetype = 2, colour = GREY) +
    geom_point(size = 2, alpha = .7) +
    lims(x = c(0, 1), y = c(0, 1)) +
    labs(x = "Membership in FIN", y = "Membership in GROWTH")
  save_apa_fig(g_nec, "fig6_qca_necessity.png", 6,
               "Necessity XY plot for FIN.",
               note = sprintf("Consistency = %.2f. Points on or above the diagonal are consistent with necessity.", neccon),
               width = 5, height = 5)
} else {
  message("[04_visualize] run 02_fsqca.R first to enable QCA XY plots.")
}

banner("04_visualize done")
cat("APA figures (300 dpi) and APA_figure_captions.txt in", PATHS$out_dir, "\n")
