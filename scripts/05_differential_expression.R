# 05_differential_expression.R
# limma differential expression, Basal vs Luminal, plus pathway scores
# Input:  data/expr_final.rds, data/geneset.csv, data/subtypes.csv
# Output: results/de_results.csv, results/scores.csv
#
# Data is log2(TPM+1), already normalized. limma, NOT DESeq2.
# Basal is the reference level, so negative logFC = higher in Basal.

library(dplyr)
library(limma)

expr_final <- readRDS("data/expr_final.rds")
geneset    <- read.csv("data/geneset.csv")
curation   <- read.csv("data/subtypes.csv")

expr_genes <- expr_final[, geneset$gene]

# match() keeps labels in the same order as the rows
labels <- curation$subtype[match(rownames(expr_genes), curation$ModelID)]

stopifnot(sum(labels == "Basal") == 30, sum(labels == "Luminal") == 16)
stopifnot(labels[rownames(expr_genes) == "ACH-000019"] == "Luminal")
stopifnot(labels[rownames(expr_genes) == "ACH-000768"] == "Basal")

# limma wants genes as rows
mat    <- t(expr_genes)
design <- model.matrix(~ labels)

fit <- lmFit(mat, design)
fit <- eBayes(fit)

results <- topTable(fit, coef = 2, number = 25, adjust.method = "BH")

stopifnot(results["CAV1", "logFC"] < -4)   # strongly higher in Basal

dir.create("results", showWarnings = FALSE)
write.csv(results, "results/de_results.csv")

# ---- Scores ----
# scale() z-scores each gene so genes on different scales contribute equally
z <- scale(expr_genes)

scores <- data.frame(
  ModelID = rownames(expr_genes),
  subtype = labels,
  score   = rowMeans(z)
)

# The 25-gene composite comes out flat: the set contains genes pointing in
# opposite directions, so averaging cancels the signal. Split by pathway.
cav_genes   <- c("CAV1","CAV2","CAVIN1","CAVIN2")
clath_genes <- c("CLTC","CLTA","CLTB","AP2M1","AP2A1","AP2B1","AP2S1")

scores$cav_score   <- rowMeans(z[, cav_genes])
scores$clath_score <- rowMeans(z[, clath_genes])

write.csv(scores, "results/scores.csv", row.names = FALSE)
