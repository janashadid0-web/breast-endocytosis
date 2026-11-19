
library(dplyr)

models <- read.csv("data/raw/Model.csv")
breast <- filter(models, OncotreeLineage == "Breast")

stopifnot(nrow(breast) == 96)

write.csv(breast, "data/breast_models.csv", row.names = FALSE)

