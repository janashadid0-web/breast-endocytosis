
library(dplyr)
library(ggplot2)

scores <- read.csv("results/scores.csv")
dir.create("figures", showWarnings = FALSE)

highlight <- scores[scores$ModelID %in% c("ACH-000019","ACH-000768"), ]
highlight$label <- ifelse(highlight$ModelID == "ACH-000019", "MCF-7", "MDA-MB-231")

p3 <- ggplot(scores, aes(x = subtype, y = cav_score)) +
  geom_boxplot(outlier.shape = NA, width = 0.5, fill = "grey95") +
  geom_jitter(width = 0.15, alpha = 0.5, size = 2) +
  geom_point(data = highlight, colour = "firebrick", size = 3.5) +
  geom_text(data = highlight, aes(label = label), hjust = -0.25,
            colour = "firebrick", size = 3.5) +
  scale_x_discrete(expand = expansion(add = 0.8)) +
  labs(x = NULL, y = "Caveolae score (mean z-score, 4 genes)",
       title = "Caveolae machinery is elevated in basal-like lines") +
  theme_minimal(base_size = 12)

ggsave("figures/fig3_caveolae_score.png", p3, width = 6.5, height = 5, dpi = 300)

