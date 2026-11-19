# 02_subtype_curation.R
# Assign Basal / Luminal / Exclude to the 96 breast lines
# Input:  data/breast_models.csv
# Output: data/subtypes.csv   [FROZEN]

library(dplyr)

breast <- read.csv("data/breast_models.csv")

curation <- select(breast, ModelID, StrippedCellLineName,
                   ModelSubtypeFeatures, OncotreeSubtype,
                   OncotreePrimaryDisease, OnboardedMedia)

curation$subtype <- NA

# Rules 1-2: explicit molecular subtype in the DepMap label
curation$subtype[grepl("basal", curation$ModelSubtypeFeatures)]   <- "Basal"
curation$subtype[grepl("luminal", curation$ModelSubtypeFeatures)] <- "Luminal"

# Rule 3: TNBC with no subtype word -> Basal
# ~70-80% of TNBC lines are basal-like. Inclusive call, flagged in limitations.
curation$subtype[curation$ModelSubtypeFeatures == "TNBC"] <- "Basal"

# Rule 4: hormone-receptor positive with no subtype word -> Luminal
curation$subtype[curation$ModelSubtypeFeatures %in%
                   c("ER+", "ER, PR+", "PR+")] <- "Luminal"

# Rule 5: HER2 and not already assigned -> exclude
# HER2-enriched is a third PAM50 subtype, neither basal nor luminal.
curation$subtype[grepl("HER2", curation$ModelSubtypeFeatures) &
                   is.na(curation$subtype)] <- "Exclude-HER2"

# Rule 6: individual Cellosaurus lookup
curation$subtype[curation$StrippedCellLineName == "ZR75B"] <- "Luminal"

# Rule 7: LAR subtype - TNBC by receptor status, luminal by expression.
# Sits between the comparison groups by definition.
curation$subtype[curation$StrippedCellLineName %in%
                   c("DU4475", "SUM185PE", "SUM52PE")] <- "Exclude-LAR"

# Rule 8: everything remaining
curation$subtype[is.na(curation$subtype)] <- "Exclude-unclassified"

stopifnot(sum(curation$subtype == "Basal") == 35)
stopifnot(sum(curation$subtype == "Luminal") == 21)

write.csv(curation, "data/subtypes.csv", row.names = FALSE)