
library(dplyr)

breast <- read.csv("data/breast_models.csv")

curation <- select(breast, ModelID, StrippedCellLineName,
                   ModelSubtypeFeatures, OncotreeSubtype,
                   OncotreePrimaryDisease, OnboardedMedia)

curation$subtype <- NA
curation$subtype[grepl("basal", curation$ModelSubtypeFeatures)]   <- "Basal"
curation$subtype[grepl("luminal", curation$ModelSubtypeFeatures)] <- "Luminal"
curation$subtype[curation$ModelSubtypeFeatures == "TNBC"] <- "Basal"
curation$subtype[curation$ModelSubtypeFeatures %in%
                 c("ER+", "ER, PR+", "PR+")] <- "Luminal"
curation$subtype[grepl("HER2", curation$ModelSubtypeFeatures) &
                 is.na(curation$subtype)] <- "Exclude-HER2"
curation$subtype[curation$StrippedCellLineName == "ZR75B"] <- "Luminal"
curation$subtype[curation$StrippedCellLineName %in%
                 c("DU4475", "SUM185PE", "SUM52PE")] <- "Exclude-LAR"
curation$subtype[is.na(curation$subtype)] <- "Exclude-unclassified"

stopifnot(sum(curation$subtype == "Basal") == 35)
stopifnot(sum(curation$subtype == "Luminal") == 21)

write.csv(curation, "data/subtypes.csv", row.names = FALSE)

