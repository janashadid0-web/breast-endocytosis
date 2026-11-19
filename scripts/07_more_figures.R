
library(dplyr)
library(ggplot2)
library(tidyr)

scores  <- read.csv("results/scores.csv")
results <- read.csv("results/de_results.csv", row.names = 1)
geneset <- read.csv("data/geneset.csv")
expr    <- readRDS("data/expr_final.rds")

dir.create("figures", showWarnings = FALSE)

# ---- Figure 1: volcano ----
results$gene <- rownames(results)
results$sig  <- results$adj.P.Val < 0.05
results$direction <- ifelse(!results$sig, "n.s.",
                     ifelse(results$logFC < 0, "Higher in Basal", "Higher in Luminal"))

p1 <- ggplot(results, aes(x = logFC, y = -log10(adj.P.Val), colour = direction)) +
  geom_point(size = 3, alpha = 0.85) +
  geom_hline(yintercept = -log10(0.05), linetype = "dashed", colour = "grey50") +
  geom_text(data = subset(results, sig), aes(label = gene),
            vjust = -0.9, size = 3, show.legend = FALSE) +
  scale_colour_manual(values = c("Higher in Basal" = "firebrick",
                                 "Higher in Luminal" = "steelblue",
                                 "n.s." = "grey70")) +
  labs(x = "log2 fold change (Luminal vs Basal)",
       y = "-log10 adjusted p",
       colour = NULL,
       title = "Differential expression across 25 endocytosis and membrane genes") +
  theme_minimal(base_size = 12) +
  theme(legend.position = "bottom")

ggsave("figures/fig1_volcano.png", p1, width = 7, height = 5.5, dpi = 300)

# ---- Figure 2: heatmap ----
z <- scale(expr[, geneset$gene])

hm <- as.data.frame(z)
hm$ModelID <- rownames(hm)
hm <- left_join(hm, scores[, c("ModelID", "subtype")], by = "ModelID")
hm <- pivot_longer(hm, cols = all_of(geneset$gene),
                   names_to = "gene", values_to = "z")
hm <- left_join(hm, geneset[, c("gene", "category")], by = "gene")

# order lines by caveolae score so the pattern is visible
line_order <- scores$ModelID[order(scores$cav_score)]
hm$ModelID <- factor(hm$ModelID, levels = line_order)
hm$gene    <- factor(hm$gene, levels = geneset$gene[order(geneset$category)])

p2 <- ggplot(hm, aes(x = ModelID, y = gene, fill = z)) +
  geom_tile() +
  facet_grid(~ subtype, scales = "free_x", space = "free_x") +
  scale_fill_gradient2(low = "steelblue", mid = "white", high = "firebrick",
                       midpoint = 0, name = "z-score") +
  labs(x = "Cell line (ordered by caveolae score)", y = NULL,
       title = "Gene set expression across 45 breast cancer cell lines") +
  theme_minimal(base_size = 11) +
  theme(axis.text.x = element_blank(),
        panel.grid = element_blank())

ggsave("figures/fig2_heatmap.png", p2, width = 9, height = 6, dpi = 300)

# ---- Figure 4: clathrin score, the negative contrast ----
long <- pivot_longer(scores, cols = c("cav_score", "clath_score"),
                     names_to = "pathway", values_to = "value")
long$pathway <- ifelse(long$pathway == "cav_score",
                       "Caveolae (4 genes)", "Clathrin (7 genes)")

p4 <- ggplot(long, aes(x = subtype, y = value, fill = subtype)) +
  geom_boxplot(outlier.shape = NA, width = 0.55, alpha = 0.6) +
  geom_jitter(width = 0.15, alpha = 0.5, size = 1.8) +
  facet_wrap(~ pathway) +
  scale_fill_manual(values = c("Basal" = "firebrick", "Luminal" = "steelblue")) +
  labs(x = NULL, y = "Pathway score (mean z-score)",
       title = "The subtype difference is specific to caveolae, not clathrin") +
  theme_minimal(base_size = 12) +
  theme(legend.position = "none")

ggsave("figures/fig4_pathway_contrast.png", p4, width = 7.5, height = 5, dpi = 300)

