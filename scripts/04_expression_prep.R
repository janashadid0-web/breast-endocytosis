# 04_expression_prep.R
# Clean the DepMap expression matrix and reduce to the analysis set
# Input:  data/raw/OmicsExpressionTPMLogp1HumanProteinCodingGenes.csv
#         data/subtypes.csv
# Output: data/expr_final.rds  (46 lines x 19,215 genes)
#
# Two quirks in the DepMap file handled here:
#   1. Rows are sequencing profiles, not cell lines. Some lines appear twice.
#   2. Gene names arrive as TSPAN6..7105. after read.csv (Entrez ID appended).

library(dplyr)

curation <- read.csv("data/subtypes.csv")

# Large file, slow to read
expr <- read.csv("data/raw/OmicsExpressionTPMLogp1HumanProteinCodingGenes.csv")

# One profile per cell line, breast lines only
expr_breast <- filter(expr,
                      IsDefaultEntryForModel == "Yes",
                      ModelID %in% curation$ModelID)

# Lines that have BOTH expression data and a Basal/Luminal call
usable      <- filter(curation, subtype %in% c("Basal", "Luminal"))
final_lines <- intersect(expr_breast$ModelID, usable$ModelID)

stopifnot(length(final_lines) == 46)

expr_final <- filter(expr_breast, ModelID %in% final_lines)

# Row names set BEFORE dropping columns, since ModelID is one of them
rownames(expr_final) <- expr_final$ModelID
expr_final <- expr_final[, 6:ncol(expr_final)]

# Strip the appended Entrez IDs
colnames(expr_final) <- sub("\\.\\..*", "", colnames(expr_final))

# Both dissertation lines must survive
stopifnot(all(c("ACH-000019", "ACH-000768") %in% rownames(expr_final)))

saveRDS(expr_final, "data/expr_final.rds")
