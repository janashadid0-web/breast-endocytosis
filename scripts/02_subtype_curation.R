
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

# Quality control: SUM102PT (ACH-001388) is low across the whole
# transcriptome (median 0.67 vs ~2.5 for comparable lines, Q1 = 0).
# Technical, not biological. Identified from the figure 2 heatmap.
curation$subtype[curation$StrippedCellLineName == "SUM102PT"] <- "Exclude-QC"

curation$subtype[is.na(curation$subtype)] <- "Exclude-unclassified"

write.csv(curation, "data/subtypes.csv", row.names = FALSE)

