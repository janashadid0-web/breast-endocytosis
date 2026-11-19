# Caveolae-associated gene expression distinguishes basal-like from luminal breast cancer cell lines

### A computational follow-up to an undergraduate investigation of DOTAP-based liposome cytotoxicity

Jana Shadid
November 2026

---

## 1. Background and rationale

An undergraduate dissertation completed at the University of Birmingham examined the
cytotoxicity of DOTAP-based liposomal formulations, prepared with a range of helper
lipids and molar ratios, in two breast cancer cell lines representing distinct molecular
subtypes: MCF-7, an oestrogen receptor positive luminal line, and MDA-MB-231, a
triple-negative basal-like line. Across formulations, MDA-MB-231 cells exhibited
consistently greater reductions in viability, with DOTAP-only liposomes reducing
viability to 12.70% at 150 ug/mL in MDA-MB-231 compared with 74.41% in MCF-7 under
their respective conditions.

The dissertation attributed this difference primarily to intrinsic cellular properties,
noting that MDA-MB-231 cells are reported to exhibit higher uptake capacity and enhanced
endocytic activity relative to MCF-7. That interpretation, however, could not be isolated
from experimental confounders, since the two cell lines were treated under materially
different conditions: MCF-7 cells received continuous 24-hour exposure in complete DMEM,
whereas MDA-MB-231 cells received transient 4-hour exposure in reduced-serum Opti-MEM
followed by a 48-hour recovery period. The dissertation's own limitations section
acknowledged that intrinsic cellular behaviour could not be separated from experimental
confounders, and a planned follow-up using DNA-complexed lipoplexes with confocal uptake
imaging could not be completed.

This project does not attempt to resolve that confound, which is not resolvable
retrospectively. It instead asks a separate and independently answerable question: whether
a molecular basis for a subtype-linked difference in endocytic capacity exists at all,
in a dataset where culture conditions are not the variable under test. If basal-like cells
do not differ from luminal cells in the expression of endocytic machinery, then the
transcriptional explanation advanced in the dissertation's discussion fails, and that
would itself be a reportable finding.

### 1.1 Research question

Do basal-like and luminal breast cancer cell lines differ systematically in the expression
of genes governing endocytic uptake and membrane composition?

### 1.2 Predictions

| | Prediction | Would have failed if |
|---|---|---|
| P1 | Basal-like lines show higher expression of endocytic machinery genes than luminal lines | No difference, or luminal higher |
| P2 | MDA-MB-231 sits in the upper portion of the basal-like distribution | It sat low within its group |
| P3 | MCF-7 sits in the lower portion of the luminal distribution | It sat high within its group |

---

## 2. Methods

### 2.1 Data source

Expression and annotation data were obtained from the Dependency Map (DepMap) portal,
release 26Q1, which houses RNA sequencing profiles for the Cancer Cell Line
Encyclopedia. Two files were used: `Model.csv`, containing cell line annotation, and
`OmicsExpressionTPMLogp1HumanProteinCodingGenes.csv`, containing expression values as
log2(TPM+1) across 19,220 protein-coding genes for 1,775 cell lines.

Cell lines in this resource are profiled under standardised conditions, which is the
property that makes the dataset appropriate for the present question.

### 2.2 Subtype assignment

DepMap subtype annotation is inconsistent, mixing histological classification, receptor
status, and molecular subtype across different fields and different lines. The
`OncotreeSubtype` field records histology (ductal, lobular, in situ) and is therefore not
informative for molecular subtyping. The `ModelSubtypeFeatures` field carries the most
usable information, annotating 81 of 96 breast lineage lines, although it mixes Neve-style
molecular terminology with receptor status.

Lines were assigned by explicit rules, applied in the following order:

1. Annotation containing "basal" was assigned Basal.
2. Annotation containing "luminal" was assigned Luminal.
3. Annotation of "TNBC" alone was assigned Basal. The majority of triple-negative lines
   are basal-like, although a minority are mesenchymal or claudin-low, so this is an
   inclusive assignment and is revisited in the limitations.
4. Annotation of hormone-receptor positivity alone (ER+, PR+) was assigned Luminal.
5. Lines annotated HER2-positive and not already assigned were excluded, HER2-enriched
   being a third molecular subtype that belongs to neither comparison group.
6. Unannotated lines were examined individually against Cellosaurus. ZR75B was assigned
   Luminal as a derivative of ZR-75-1, which is Luminal A. 600MPE was excluded because
   published sources disagree on its HER2 status. VP229 and VP267 were excluded for
   incomplete receptor data, and because both derive from the same patient and are
   therefore not independent samples. Non-cancerous lines, a ductal carcinoma in situ
   line, and lines with insufficient published characterisation were excluded.
7. Three lines annotated "luminal TNBC" (DU4475, SUM185PE, SUM52PE) were excluded. This
   annotation is not an error but describes the luminal androgen receptor phenotype, which
   is triple-negative by receptor status while clustering with luminal lines by expression.
   Such lines sit between the comparison groups by definition and cannot be assigned to
   either without misrepresenting them.
8. SUM102PT was excluded on quality grounds. It was identified as an outlier during
   visual inspection of the expression heatmap, showing uniformly depressed values across
   the gene set; subsequent examination confirmed a transcriptome-wide median of 0.67
   against approximately 2.5 for comparable lines, with the first quartile at zero,
   indicating a technical rather than biological profile.

All assignments, together with their sources and the reasoning behind each exclusion, are
recorded in `data/subtypes.csv` and in the curation script.

### 2.3 Gene set

Twenty-five genes were curated from the lipid nanoparticle uptake literature, spanning
clathrin machinery (CLTC, CLTA, CLTB, AP2M1, AP2A1, AP2B1, AP2S1), dynamin-mediated
scission (DNM1, DNM2), caveolae (CAV1, CAV2, CAVIN1, CAVIN2), macropinocytosis (RAC1,
PAK1, CTBP1), lipid synthesis and handling (SCD, FASN, SREBF1, SREBF2, LDLR, ACACA), and
membrane remodelling (ABCA1, ABCG1, SMPD1).

The gene set was committed to version control before any differential expression analysis
was run, so that the timestamp establishes that gene selection preceded knowledge of the
results. A deliberately compact, hypothesis-driven set was preferred over a broader
Gene Ontology-derived set, both because the available sample size does not support testing
several hundred genes and because a pre-specified set is more straightforwardly defensible.

### 2.4 Analysis set

| Stage | n |
|---|---|
| Breast lineage lines in DepMap | 96 |
| Assigned Basal or Luminal | 56 |
| With expression data available | 71 |
| Final analysis set | 45 |

The final set comprised 29 basal-like and 16 luminal lines. Both MCF-7 (ACH-000019) and
MDA-MB-231 (ACH-000768) were retained.

The expression matrix required two corrections before use. Rows correspond to sequencing
profiles rather than to cell lines, with some lines appearing more than once, so the
dataset was filtered to the profile designated default for each line. Gene identifiers
carry appended Entrez numbers following import, which were removed to permit matching
against the gene set.

### 2.5 Statistical analysis

Differential expression between subtypes was assessed using linear models with empirical
Bayes moderation of variance estimates, implemented in limma. Because DepMap expression
values are supplied as log2(TPM+1) and are therefore already normalised, count-based
methods such as DESeq2 were not appropriate. Benjamini-Hochberg correction was applied
across the 25 genes of the pre-specified set rather than transcriptome-wide, the gene set
constituting the relevant testing family.

Pathway scores were computed by converting each gene to a z-score across lines, so that
genes expressed at different absolute levels contribute equally, and then averaging across
the genes of a given pathway for each line.

All analysis scripts include assertions on sample counts and effect direction, so that any
change in the underlying data causes the pipeline to fail rather than silently to produce
a different result.

---

## 3. Results

### 3.1 Differential expression

Nine of the 25 genes reached significance at an adjusted p-value below 0.05. The four
largest effects were as follows.

| Gene | log2FC | adj. p | Higher in |
|---|---|---|---|
| CAV1 | -4.92 | 1.9e-07 | Basal |
| CAV2 | -4.34 | 2.2e-08 | Basal |
| CAVIN1 | -4.06 | 2.2e-08 | Basal |
| ABCG1 | +2.80 | 6.8e-10 | Luminal |

Negative values denote higher expression in basal-like lines, basal-like being the
reference level. The remaining significant genes were CAVIN2, ABCA1 and LDLR, higher in
basal-like lines, and SREBF1 and FASN, higher in luminal lines, all with effect sizes
below one log2 unit.

The magnitude of the caveolar differences is considerable. A log2 fold change of -4.92 for
CAV1 corresponds to roughly a thirty-fold difference in expression between the two groups.

### 3.2 The difference is pathway-specific

No gene of the clathrin pathway reached significance. CLTC, CLTA, CLTB, AP2M1, AP2A1 and
AP2B1, together with both dynamins, showed effect sizes near zero and adjusted p-values
approaching unity.

This specificity is visible in the pathway scores.

| Score | Basal | Luminal |
|---|---|---|
| Caveolae (4 genes) | +0.46 | -0.84 |
| Clathrin (7 genes) | -0.09 | +0.16 |

A composite score computed across all 25 genes was essentially flat between the two groups,
because the set contains genes differing in opposite directions whose contributions cancel.
This is recorded rather than omitted, since the failure of the composite measure is what
motivated analysis at the level of individual pathways and is itself informative about how
such scores should be constructed.

### 3.3 Position of the dissertation cell lines

| Line | Subtype | Caveolae score | Group mean |
|---|---|---|---|
| MDA-MB-231 | Basal | +1.67 | +0.46 |
| MCF-7 | Luminal | -0.98 | -0.84 |

MDA-MB-231 sits well above the mean of its own group, and MCF-7 below the mean of its own
group. Predictions P2 and P3 are therefore satisfied, and the two lines used in the
dissertation occupy opposite ends of the caveolar distribution in the direction that the
observed sensitivity difference would require.

Prediction P1 is satisfied only in part, and in a more specific form than was anticipated.
Basal-like lines do not show generally elevated endocytic gene expression; they show
elevated expression confined to the caveolar pathway.

---

## 4. Discussion

### 4.1 What the result shows

The analysis identifies a large, highly significant and pathway-restricted difference
between basal-like and luminal breast cancer cell lines in the expression of caveolae-
associated genes, with no corresponding difference in clathrin machinery. The two cell
lines used in the original dissertation sit at opposite extremes of this distribution in
the direction that would be required if differential uptake capacity contributed to their
differing sensitivity to DOTAP-based liposomes.

The specificity of the finding is of greater interest than its magnitude. A general
elevation of endocytic machinery across basal-like lines would have been consistent with
the dissertation's interpretation but would not have indicated a mechanism. A difference
confined to one internalisation pathway generates a testable prediction: if caveolae-
mediated uptake contributes materially to the observed sensitivity difference, then
pharmacological or genetic disruption of CAV1 should attenuate that difference, whereas
disruption of clathrin-mediated uptake should not.

### 4.2 Relation to the secondary lipid findings

Several genes of lipid handling also differed between subtypes. The most directly relevant
is LDLR, the low-density lipoprotein receptor, which was elevated in basal-like lines.
LDLR mediates receptor-dependent internalisation of lipoprotein particles, so a subtype
difference here constitutes a second uptake-related difference, pointing in the same
direction as the caveolar finding but through an independent route.

Alongside this, ABCG1 and ABCA1, which mediate cholesterol efflux, and SREBF1 and FASN,
which govern lipid synthesis, separated the groups with smaller but significant effects.
These bear in principle on the behaviour of lipid-based delivery vehicles, since membrane
lipid composition influences both fusion and the curvature behaviour that the dissertation
identified as central to the differing cytotoxicity of DOPE and DOPA-containing
formulations. All of these effects are an order of magnitude smaller than the caveolar
differences, and no mechanistic claim is advanced on the basis of them here.

### 4.3 The principal alternative explanation

The caveolar result admits an interpretation that does not involve uptake capacity at all,
and this interpretation must be taken seriously rather than set aside.

Caveolin-1 is strongly associated with the mesenchymal phenotype in breast cancer. In a
study of 38 breast cancer cell lines, Caveolin-1 was identified as a marker of epithelial
to mesenchymal transition with complete specificity and sensitivity, discriminating lines
that had undergone the transition from those that had not irrespective of E-cadherin
status (Hollestelle et al., 2013). Other work has reported that mammary tumour cells with
epithelial characteristics lack caveolin-1 while mesenchymal cells express it (Thompson et al., 2012), and that
CAV1 is elevated specifically in triple-negative lines of mesenchymal and basal-like
subtype.

This matters because the basal-like group assembled here is enriched for basal B and
claudin-low lines, which are mesenchymal in character, and because MDA-MB-231 is the
archetypal line of that group. CAV2 and CAVIN1 are co-regulated with CAV1, so their
behaviour does not constitute independent confirmation.

The consequence is that the present analysis cannot distinguish between two accounts. The
first holds that basal-like cells possess greater caveolar uptake capacity, which
contributes to their greater sensitivity to lipid nanoparticles. The second holds that the
basal-like group is mesenchymal, that caveolin expression is a property of the mesenchymal
state, and that the association with nanoparticle sensitivity is either coincidental or
mediated by some other feature of that state, such as membrane fluidity or composition.

Four considerations bear on this without resolving it. The restriction of the effect to
caveolae while clathrin machinery is unchanged is more readily explained by a specific
pathway difference than by a broad phenotypic one, although caveolin's role as an EMT
marker is itself specific. The elevation of LDLR in basal-like lines is modest evidence
against the pure phenotype-marker reading, since LDLR is an uptake-related gene and is not
a recognised marker of the mesenchymal state, so it represents a subtype difference in
internalisation capacity that the EMT account does not readily explain. Against this, the
accompanying differences in cholesterol handling and lipid synthesis are consistent with a
membrane-composition account, which would favour the second interpretation. And the
direction of the effect is in any case the direction predicted in advance, which is weak
evidence but not no evidence.

The honest position is that this analysis establishes an association and not a mechanism,
and that a well-informed reader will raise the mesenchymal explanation immediately. The
appropriate response is to state it, as here, and to identify what would settle it.

### 4.4 What would resolve the question

The question is resolvable experimentally. Measuring uptake of labelled DOTAP-based
liposomes across a panel of breast cancer lines spanning the caveolar expression range,
rather than in two lines alone, would establish whether expression predicts uptake.
Including basal A lines, which are basal-like without being mesenchymal, would separate
the subtype account from the EMT account directly. Comparing uptake under CAV1 knockdown
against clathrin inhibition would test the pathway specificity claim. The confocal imaging
originally planned for the dissertation, extended across a panel rather than a pair, is
very close to the right experiment.

---

## 5. Limitations

**Transcript abundance is not protein abundance and is not uptake rate.** This is the
largest inferential gap in the work. Expression of caveolar genes indicates capacity for
caveolae formation; it does not establish that caveolae are formed, that they internalise
lipid nanoparticles, or that they do so at different rates between subtypes.

**The mesenchymal confound.** As set out in section 4.3, caveolin expression tracks the
mesenchymal phenotype closely enough that the subtype interpretation cannot be isolated
from it within this dataset.

**No lipid nanoparticle screening data exists across these cell lines.** The connection to
the dissertation observation rests on two cell lines and is therefore indirect. No
dataset profiling nanoparticle uptake or sensitivity across a breast cancer cell line
panel is publicly available.

**Cell lines are not tumours.** Decades of passage and adaptation to culture select for
properties that may not reflect primary tissue, and the caveolar difference in particular
may be influenced by growth on plastic.

**The binary classification is coarse.** Basal A and basal B lines differ substantially
from one another and were not separated. Given the argument of section 4.3, this is the
most consequential simplification in the analysis, and separating them would be the first
refinement to make.

**Subtype assignment involved judgment.** DepMap annotation did not permit purely
mechanical classification. The rules applied are documented and the exclusions are
reasoned, but a different analyst applying different rules would obtain a somewhat
different set, particularly in the treatment of triple-negative lines lacking molecular
annotation.

**Statistical power is modest.** Sixteen luminal lines is a small group. The caveolar
effects are large enough that this is unlikely to affect them, but the smaller effects
among the lipid handling genes should be treated as provisional.

**The dissertation confound is not resolved.** The media and incubation differences
between MCF-7 and MDA-MB-231 in the original experiments remain uninterpretable. This
analysis demonstrates that a candidate molecular basis exists; it does not establish that
this basis operated in those experiments.

---

## 6. Conclusion

Basal-like and luminal breast cancer cell lines differ markedly in the expression of
caveolae-associated genes, with no corresponding difference in clathrin machinery, and
MCF-7 and MDA-MB-231 occupy opposite extremes of this distribution in the direction that
the sensitivity difference observed in the original dissertation would require. The
difference is specific to one internalisation pathway rather than general to endocytosis,
which converts a loose explanatory suggestion into a testable prediction.

The finding is an association. Caveolin expression is closely tied to the mesenchymal
phenotype that characterises much of the basal-like group, and the present analysis cannot
distinguish a pathway-capacity explanation from a phenotype-marker explanation. Resolving
that distinction requires uptake measurement across a cell line panel rather than
expression analysis, and that experiment is a direct extension of the confocal work
originally planned.

---

## 7. Data and code availability

All analysis code, curated subtype assignments, the frozen gene set, and the figures
reproduced here are available at `github.com/janashadid0-web/breast-endocytosis`. Raw
DepMap files are not redistributed and should be obtained from the DepMap portal.

## 8. References

Hollestelle A, Peeters JK, Smid M, et al. Loss of E-cadherin is not a necessity for
epithelial to mesenchymal transition in human breast cancer. *Breast Cancer Research and
Treatment* 2013.

Benjamini Y, Hochberg Y. Controlling the false discovery rate: a practical and powerful
approach to multiple testing. *Journal of the Royal Statistical Society, Series B*
1995;57(1):289-300.

Broad Institute. DepMap 26Q1 Public. Cancer Dependency Map. depmap.org

Cellosaurus. SIB Swiss Institute of Bioinformatics. cellosaurus.org

Hollestelle A, Peeters JK, Smid M, et al. Loss of E-cadherin is not a necessity for
epithelial to mesenchymal transition in human breast cancer. *Breast Cancer Research and
Treatment* 2013;138(1):47-57.

Neve RM, Chin K, Fridlyand J, et al. A collection of breast cancer cell lines for the
study of functionally distinct cancer subtypes. *Cancer Cell* 2006;10(6):515-527.

Ritchie ME, Phipson B, Wu D, et al. limma powers differential expression analyses for
RNA-sequencing and microarray studies. *Nucleic Acids Research* 2015;43(7):e47.

Shadid J. Investigating the Effect of Lipid Composition and Molar Ratio on the
Cytotoxicity of DOTAP-Based Gene Therapy Vectors in MCF-7 and MDA-MB-231 Breast Cancer
Cells. BSc Biomedical Science dissertation, University of Birmingham, 2026.

Thompson DE, Siwicky MD, Moorehead RA. Caveolin-1 expression is elevated in claudin-low
mammary tumor cells. *Cancer Cell International* 2012;12:6.
