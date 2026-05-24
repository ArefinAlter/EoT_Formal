# =====================================================================
# apa_helpers.R  --  shared APA styling for tables (flextable) and
# figures (ggplot2). Sourced by 04_visualize.R and 05_tables_apa.R.
#
# Scope note: the APA 7 manual does not define a format for fsQCA
# configurational tables (it predates their common use). We therefore
# apply APA's GENERAL table rules -- table number, italic title,
# horizontal rules only (no vertical lines), a Note line -- and follow
# QCA reporting conventions (Schneider & Wagemann) for the content.
# =====================================================================
suppressMessages({ library(flextable); library(officer); library(ggplot2) })

## ---- figures: APA ggplot theme ------------------------------------
theme_apa_gg <- function(base_size = 11, base_family = APA$fig_font) {
  theme_classic(base_size = base_size, base_family = base_family) +
    theme(
      plot.title    = element_blank(),           # APA caption sits below, in the doc
      plot.subtitle = element_blank(),
      axis.title    = element_text(face = "plain"),
      axis.line     = element_line(linewidth = 0.4, colour = "black"),
      panel.grid    = element_blank(),
      legend.title  = element_text(face = "plain"),
      legend.position = "right",
      plot.caption  = element_text(hjust = 0, size = base_size - 1)
    )
}

# Greyscale-safe qualitative fills (works in B/W print)
APA_GREYS <- c("#2b2b2b", "#6e6e6e", "#9e9e9e", "#c4c4c4", "#e0e0e0")

# Save a figure at APA spec and write its caption to a side-car file.
save_apa_fig <- function(plot, file, fig_no, title, note = NULL,
                         width = 6.5, height = 4) {
  ggsave(opath(file), plot, width = width, height = height,
         dpi = APA$fig_dpi, bg = "white")
  cap <- sprintf("Figure %d\n%s%s", fig_no, title,
                 if (is.null(note)) "" else paste0("\nNote. ", note))
  if (IS_MOCK) cap <- paste0(cap, "  [ILLUSTRATIVE; mock data]")
  cat(cap, "\n\n", file = opath("APA_figure_captions.txt"), append = TRUE)
  invisible(plot)
}

## ---- tables: APA flextable styler ---------------------------------
# Build an APA-styled flextable with title (caption) and Note line.
apa_ft <- function(df, table_no, title, note = NULL, dec = APA$dec_fit) {
  fmt_col <- function(v) {
    if (is.numeric(v)) {
      if (all(v == floor(v), na.rm = TRUE)) return(formatC(v, format = "d"))
      return(formatC(round(v, dec), format = "f", digits = dec))
    }
    sv <- suppressWarnings(as.numeric(v)); ok <- !is.na(sv)   # character col
    if (any(ok)) {
      whole <- all(sv[ok] == floor(sv[ok]))
      v[ok] <- if (whole) formatC(sv[ok], format = "d")
               else formatC(round(sv[ok], dec), format = "f", digits = dec)
    }
    v
  }
  is_numlike <- vapply(df, function(v) is.numeric(v) ||
                         any(!is.na(suppressWarnings(as.numeric(v)))), logical(1))
  df[] <- lapply(df, fmt_col)
  if (IS_MOCK) title <- paste0(title, " (illustrative; mock data)")

  ft <- flextable(df)
  ft <- theme_apa(ft)                                  # APA: horizontal rules only
  ft <- set_caption(ft, caption = sprintf("Table %d. %s", table_no, title))
  if (!is.null(note)) {
    ft <- add_footer_lines(ft, values = paste0("Note. ", note))
    ft <- merge_at(ft, i = 1, part = "footer")
  }
  ft <- font(ft, fontname = APA$font, part = "all")
  ft <- fontsize(ft, size = 10, part = "all")
  if (any(is_numlike)) ft <- align(ft, j = which(is_numlike), align = "center", part = "all")
  ft <- autofit(ft)
  ft
}

# Collect tables into one Word document.
apa_doc_new   <- function() officer::read_docx()
apa_doc_add   <- function(doc, ft, landscape = FALSE) {
  doc <- flextable::body_add_flextable(doc, ft)
  doc <- officer::body_add_par(doc, "")
  doc
}
apa_doc_save  <- function(doc, file) print(doc, target = opath(file))
