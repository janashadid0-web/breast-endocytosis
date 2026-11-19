
# Subtype-specific endocytosis gene expression in breast cancer cell lines

A computational follow-up to an undergraduate dissertation on DOTAP lipid
nanoparticle cytotoxicity in MCF-7 and MDA-MB-231.

## Question

Do basal-like and luminal breast cancer cell lines differ systematically in
expression of genes governing endocytic uptake and membrane composition?

## Background

An undergraduate dissertation measured lipid nanoparticle cytotoxicity in two
breast cancer cell lines. MDA-MB-231 (basal-like) was consistently more
sensitive than MCF-7 (luminal). Because the two lines were cultured under
different conditions, a biological explanation could not be separated from an
experimental one.

This project does not attempt to resolve that confound. It asks a separate
question: whether a molecular basis for a subtype-linked difference in
endocytic capacity exists at all, in data where culture conditions are not the
variable under test.

## Data

DepMap Public release [RECORD VERSION HERE], from depmap.org

- `Model.csv` — cell line annotation
- `OmicsExpressionTPMLogp1HumanProteinCodingGenes.csv` — RNA-seq, log2(TPM+1)

Raw data is not included in this repository (the expression file exceeds the
GitHub file size limit). Download both files from the DepMap portal and place
them in `data/raw/`.

## Analysis set

| Stage | n |
|---|---|
| Breast lines in DepMap | 96 |
| With a confident Basal or Luminal call | 56 |
| With expression data | 71 |
| Final analysis set | 45 |

29 Basal, 16 Luminal. Both MCF-7 (ACH-000019) and MDA-MB-231 (ACH-000768) are
included.

Subtype assignment was manual. DepMap annotations are inconsistent, mixing
receptor status with molecular subtype, so lines were assigned by explicit
rules recorded in `scripts/02_subtype_curation.R`. HER2-enriched lines were
excluded as a third subtype. Three luminal androgen receptor lines were
excluded because they sit between the comparison groups by definition. One
line (SUM102PT) was excluded on quality grounds after a transcriptome-wide low
expression profile was identified from the heatmap.

## Gene set

25 genes, curated from the lipid nanoparticle uptake literature and frozen
before any differential expression was run: clathrin machinery, dynamin
scission, caveolae, macropinocytosis, lipid synthesis, membrane remodeling.
See `data/geneset.csv`.

## Method

limma linear models with empirical Bayes moderation. DepMap expression arrives
as log2(TPM+1), already normalized, so count-based methods such as DESeq2 are
not appropriate. Benjamini-Hochberg correction was applied across the 25 genes
only, since the gene set was pre-specified.

## Result

The subtype difference is specific to caveolae-mediated uptake, not
endocytosis in general.

| Gene | log2FC | adj. p | Higher in |
|---|---|---|---|
| CAV1 | -4.92 | 1.9e-07 | Basal |
| CAV2 | -4.34 | 2.2e-08 | Basal |
| CAVIN1 | -4.06 | 2.2e-08 | Basal |
| ABCG1 | 2.80 | 6.8e-10 | Luminal |

Negative log2FC indicates higher expression in Basal lines.

All four caveolae genes separate strongly. No clathrin gene reaches
significance. Pathway scores: caveolae 0.46 in Basal against -0.84 in Luminal;
clathrin -0.12 against 0.22.

MDA-MB-231 scores 1.68 on the caveolae score, above the basal group mean.
MCF-7 scores -0.99, below the luminal group mean. Both lines sit where the
subtype pattern predicts.

## Limitations

1. Transcript abundance is not protein abundance and is not uptake rate. This
   is the largest inferential gap in the project.
2. No lipid nanoparticle screening data exists across these cell lines, so the
   link to the dissertation observation remains indirect.
3. Cell lines are not tumours.
4. The basal and luminal binary is coarse. Basal A and Basal B lines were not
   separated.
5. 16 luminal lines is modest power. Effect sizes matter more than p-values.
6. The dissertation confound is not resolved by this work.

## Reproducing

Download the DepMap files into `data/raw/`, then run in order:

```r
source("scripts/01_filter_breast.R")
source("scripts/02_subtype_curation.R")
source("scripts/03_geneset.R")
source("scripts/04_expression_prep.R")
source("scripts/05_differential_expression.R")
source("scripts/06_figures.R")
source("scripts/07_more_figures.R")
```

Requires R with dplyr, ggplot2, tidyr and limma (Bioconductor).

Scripts contain `stopifnot` checks on sample counts and effect direction, so a
change in the underlying data will fail loudly rather than silently alter the
result.

