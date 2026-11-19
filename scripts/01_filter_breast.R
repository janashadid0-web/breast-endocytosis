# 01_filter_breast.R
# DepMap Model.csv -> 96 breast cancer cell lines
# Output: data/breast_models.csv

library(dplyr)

models <- read.csv("data/raw/Model.csv")

breast <- filter(models, OncotreeLineage == "Breast")

stopifnot(nrow(breast) == 96)

write.csv(breast, "data/breast_models.csv", row.names = FALSE)