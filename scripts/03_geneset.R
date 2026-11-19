# 03_geneset.R
# Literature-curated endocytosis and membrane gene set
# Output: data/geneset.csv   [FROZEN before any differential expression]

geneset <- data.frame(
  gene = c("CLTC","CLTA","CLTB","AP2M1","AP2A1","AP2B1","AP2S1",
           "DNM1","DNM2",
           "CAV1","CAV2","CAVIN1","CAVIN2",
           "RAC1","PAK1","CTBP1",
           "SCD","FASN","SREBF1","SREBF2","LDLR","ACACA",
           "ABCA1","ABCG1","SMPD1"),
  category = c(rep("clathrin", 7),
               rep("scission", 2),
               rep("caveolae", 4),
               rep("macropinocytosis", 3),
               rep("lipid_synthesis", 6),
               rep("membrane_remodeling", 3)),
  source = "literature"
)

stopifnot(nrow(geneset) == 25)

write.csv(geneset, "data/geneset.csv", row.names = FALSE)