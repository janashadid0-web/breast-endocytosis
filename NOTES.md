# Project notes

Running log. Add a new entry each session — what was done, where it stopped,
what's next. Newest at the bottom.

---

## Session 1 — 8 September 2026

**Environment**
- R and RStudio installed (macOS, M4)
- Packages installed and confirmed loading: dplyr, ggplot2, limma, GSVA, BiocManager
- RStudio Project created: `breast-endocytosis`

**Data downloaded**
- DepMap Public release — **RECORD THE VERSION NUMBER HERE (e.g. 25Q2)**
- `data/raw/Model.csv` — cell line annotation, 49 columns
- `data/raw/OmicsExpressionTPMLogp1HumanProteinCodingGenes.csv` — expression, not yet loaded
- Note: file name differs from older docs; current release uses
  `OmicsExpressionTPMLogp1HumanProteinCodingGenes.csv`

**Work done**
- Filtered `Model.csv` to breast lineage → **96 lines**
- Saved as `data/breast_models.csv`
- Confirmed both dissertation lines present:
  - MCF-7 = `ACH-000019` — annotated `ER+`
  - MDA-MB-231 = `ACH-000768` — annotated `basal_B TNBC`

**Key findings**
- `OncotreeSubtype` is **histological** (ductal/lobular/in situ) — useless for
  molecular subtyping. Do not use.
- `ModelSubtypeFeatures` is the useful column. 81 of 96 lines annotated,
  15 blank. Uses Neve-style basal_A / basal_B / luminal terminology.
- `PatientSubtypeFeatures` is entirely empty — ignore it.
- `OnboardedMedia` and `FormulationID` record culture media per line.
  MCF-7 = EMEM + insulin, MDA-MB-231 = RPMI. **The media difference from the
  dissertation is conventional for these lines, not arbitrary.** Worth a
  sentence in limitations. Also worth checking whether media differs
  systematically between basal and luminal lines across all 96 — if it does,
  that is the dissertation confound reappearing at dataset level.
- Both dissertation lines are metastatic pleural effusion samples, not primary
  tumours.

**Rough subtype breakdown from `ModelSubtypeFeatures`**

| Group | n | Note |
|---|---|---|
| Clearly basal (basal / basal_A / basal_B) | ~28 | Usable as-is |
| Clearly luminal | ~19 | Usable as-is |
| Receptor status only (TNBC, HER2+, ER+, PR+) | ~34 | Needs judgment call |
| Blank | 15 | Needs external source or exclusion |

**Stopped at:** breast models saved. Expression file downloaded but never loaded.

---

## Next session — Stage 2, subtype curation

Target: produce `data/subtypes.csv`. 2–3 hours. Judgment work, not coding.

Decisions to make and document per line:
1. TNBC without a subtype word → assign basal, or exclude? Most TNBC lines are
   basal but not all (some mesenchymal / claudin-low).
2. HER2+ lines (~16) → spec says exclude. Neither basal nor luminal in PAM50 terms.
3. `luminal TNBC` (3 lines) → internally contradictory. Check individually or exclude.
4. Blanks (15) → check against Neve et al. 2006 / Cellosaurus, or exclude.
5. `Immortalized Breast Cells` (4) → exclude, non-cancerous.
6. `Ductal Carcinoma In Situ` (5) → pre-invasive, probably exclude. Decide and record.

Output columns: `model_id`, `cell_line`, `subtype`, `source`, `notes`

**Bring decisions 1 and 3 to Dr. El-Hadidi in week 3** — genuine methodological
questions with more than one defensible answer.

---

## Still outstanding from week 1

- `left_join` (needed to join expression to annotation)
- One ggplot
- Git + GitHub: account, repo, `.gitignore` with `data/raw/`, push spec and notes

---

## Reminders

- DepMap expression is log2(TPM+1) — **use limma, never DESeq2**
- Freeze `subtypes.csv` and `geneset.csv` in git BEFORE running any differential expression
- Pin the DepMap release version in the README








 Session 2 — 29 September 2026

**Stage 2 complete: subtype curation**

Produced `data/subtypes.csv` from the 96 breast lines.

**Final counts**

| Group | n |
|---|---|
| Basal | 35 |
| Luminal | 24 |
| Exclude-HER2 | 22 |
| Exclude-unclassified | 15 |
| **Usable** | **59** |

**Rules applied, in order**

1. Label contains "basal" → Basal (28 lines)
2. Label contains "luminal" → Luminal (19 lines)
3. Label exactly "TNBC" → Basal (7 lines). Rationale: ~70-80% of TNBC
   lines are basal-like. Inclusive call, flagged in limitations.
4. Label in ER+ / "ER, PR+" / PR+ → Luminal (4 lines). ER positivity maps
   reliably onto luminal.
5. Label mentions HER2 and not already assigned → Exclude-HER2 (22 lines).
   HER2-enriched is a third PAM50 subtype, neither basal nor luminal.
6. Individual lookups on Cellosaurus for the 16 unannotated
7. Everything remaining → Exclude-unclassified (15 lines)

**Individual lookups**

- **ZR75B** → Luminal. Derivative of ZR-75-1, which is Luminal A.
- **600MPE** → Excluded. Sources conflict on HER2 status: ER+/HER2- in one,
  ER+/HER2+ in another. Chose exclusion over overriding the HER2 rule on
  ambiguous evidence.
- **VP267** → Excluded. ER-negative confirmed, but no HER2 data, so
  triple-negative status cannot be established.
- **VP229** → Excluded. No receptor data. Also same patient as VP267
  (primary and recurrence 14 months apart), so not independent samples.
- **HMEL, MCF10A, HBL100, MCF12A** → Excluded, non-cancerous
- **HCC2688** → Excluded, DCIS, pre-invasive
- **MX1, SKBR5, SKBR7, MRKNU1, OCUBM, MACLS2, BCK4** → Excluded,
  insufficient characterisation

**OPEN ISSUE — unresolved**

3 lines are labelled `luminal TNBC`, which is internally contradictory. They
matched both rule 1 and rule 2, so rule 2 overwrote them and they are
currently classified **Luminal**. This was never checked individually.
**Resolve before running differential expression.** Identify them with:

```r
filter(curation, grepl("luminal", ModelSubtypeFeatures) &
                 grepl("TNBC", ModelSubtypeFeatures))
```

**Stopped at:** `subtypes.csv` saved.

**Next session — Stage 3, gene set curation.** Target: `data/geneset.csv`.
Must be frozen in git before any differential expression.

**Also due:** email Dr. El-Hadidi. Two questions worth his time — is
TNBC→Basal defensible, and should ER+/PR+/HER2+ lines count as luminal B
rather than being excluded?




---

## Session 3 — 29 September 2026

**Stages 2 and 3 complete. Ready for differential expression.**

### Resolved: the three `luminal TNBC` lines

DU4475, SUM185PE, SUM52PE. Not a labelling error — these are the luminal
androgen receptor (LAR) subtype: triple-negative by receptor status, luminal
by expression pattern. They sit between the two comparison groups by
definition, so including them in either misrepresents them.

**Decision: excluded** (`Exclude-LAR`). Revised counts: Basal 35, Luminal 21.

Worth raising with El-Hadidi — this is a real methodological fork, not an
error.

### Stage 3: gene set

`data/geneset.csv` — **25 genes, literature-curated, FROZEN**

| Category | Genes |
|---|---|
| Clathrin | CLTC, CLTA, CLTB, AP2M1, AP2A1, AP2B1, AP2S1 |
| Scission | DNM1, DNM2 |
| Caveolae | CAV1, CAV2, CAVIN1, CAVIN2 |
| Macropinocytosis | RAC1, PAK1, CTBP1 |
| Lipid synthesis | SCD, FASN, SREBF1, SREBF2, LDLR, ACACA |
| Membrane remodeling | ABCA1, ABCG1, SMPD1 |

**Open decision:** whether to add MSigDB GO terms (~300 genes) or stay at 25.
Currently leaning toward staying at 25 — with 16 luminal lines there isn't
power to chase 300 genes, and a pre-specified hypothesis-driven set is
easier to defend. Ask El-Hadidi.

All 25 confirmed present in the expression data.

### Expression file — two quirks worth recording in methods

1. **Rows are sequencing profiles, not cell lines.** Some lines appear more
   than once. Filtered on `IsDefaultEntryForModel == "Yes"`. One duplicate
   removed among the breast lines.
2. **Gene names carry Entrez IDs** in the form `TSPAN6..7105.` after
   `read.csv`. Stripped with `sub("\\.\\..*", "", ...)`.

### Final analysis set

| Stage | n |
|---|---|
| Breast lines in DepMap | 96 |
| With Basal/Luminal call | 56 |
| With expression data | 71 |
| **Both (final)** | **46** |

**30 Basal, 16 Luminal.** Both ACH-000019 (MCF-7) and ACH-000768
(MDA-MB-231) present.

**Report the 96 → 46 attrition in methods** — where lines were lost and why.

**Power caveat:** 16 luminal lines is modest. Effect sizes matter more than
p-values here, and it's a further argument for the tight gene set.

### Files saved

- `data/subtypes.csv` — subtype calls, frozen
- `data/geneset.csv` — 25 genes, frozen
- `data/expr_final.rds` — cleaned matrix, 46 lines x 19,215 genes

RDS not CSV for the matrix, so row names (ACH codes) survive. Reload with
`readRDS()`.

### Next session — Stage 4, differential expression

limma on log2(TPM+1). **Not DESeq2** — data is already normalized.
BH correction across the 25 genes only. Report effect sizes alongside p-values.

### Still outstanding

- **Email Dr. El-Hadidi.** Three questions now: TNBC→Basal defensible?
  ER+/PR+/HER2+ lines as luminal B rather than excluded? Gene set at 25 or
  expand?
- Git/GitHub setup — repo still not created
- `left_join` and ggplot, never covered




---

## Sessions 4–5 — 29 September 2026

**Stages 4 and 5 complete. The project has a result.**

### Stage 4: differential expression

limma on log2(TPM+1), 25 genes, 46 lines (30 Basal / 16 Luminal),
BH correction across the gene set.

**Sign convention: Basal is the reference group, so negative logFC = higher
in Basal, positive = higher in Luminal.**

Significant at adj.P < 0.05 (8 of 25 genes):

| Gene | logFC | adj.P | Higher in |
|---|---|---|---|
| CAV1 | -4.92 | 8.2e-08 | Basal |
| CAV2 | -4.31 | 1.5e-08 | Basal |
| CAVIN1 | -3.96 | 3.2e-08 | Basal |
| CAVIN2 | -0.97 | 0.041 | Basal |
| ABCG1 | +2.76 | 8.5e-10 | Luminal |
| SREBF1 | +0.96 | 0.023 | Luminal |
| FASN | +0.90 | 0.023 | Luminal |
| ABCA1 | -0.80 | 0.033 | Basal |

**Not significant:** every clathrin gene (CLTC, CLTA, CLTB, AP2M1, AP2A1,
AP2B1), both dynamins, RAC1, PAK1, CTBP1, SCD, SREBF2, ACACA, SMPD1.
AP2S1 was borderline (adj.P = 0.052).

### The finding

**The subtype difference is specific to caveolae-mediated uptake, not
endocytosis in general.** All four caveolae genes separate strongly and in
the same direction (basal high), while the entire clathrin pathway is flat.
CAV1 at logFC -4.9 is roughly a 30-fold difference.

This is a more useful result than the original hypothesis predicted. "Basal
cells do more endocytosis" would have been vague; a pathway-specific
difference points at a mechanism someone could test.

Secondary signal in lipid handling: ABCG1 and ABCA1 (cholesterol efflux) and
SREBF1/FASN (lipid synthesis) all differ, though with much smaller effects.

### Stage 5: scoring

**The composite 25-gene score came out flat** — Basal 0.008, Luminal -0.015.
Cause: the set contains genes pointing in opposite directions, so averaging
cancels the signal. Record this in methods; trying the obvious summary
measure and finding it washes out the signal is part of the reasoning, not a
mistake to hide.

Split by pathway instead:

| Score | Basal | Luminal |
|---|---|---|
| Caveolae (4 genes) | **+0.45** | **-0.84** |
| Clathrin (7 genes) | -0.12 | +0.22 |

Clean separation on caveolae, nothing on clathrin. Consistent with the DE
table.

### The dissertation link — P2 and P3 both hold

| Line | Subtype | Caveolae score | Group mean |
|---|---|---|---|
| MDA-MB-231 (ACH-000768) | Basal | **+1.68** | +0.45 |
| MCF-7 (ACH-000019) | Luminal | **-0.99** | -0.84 |

MDA-MB-231 sits well above the basal average, MCF-7 below the luminal
average. Both lines land at opposite ends of the caveolae distribution, in
the direction the dissertation's sensitivity difference would predict.

**What this does not show:** transcript levels are not uptake rates, and the
media/incubation confound in the dissertation remains unresolved. The claim
is that a plausible molecular basis exists and is pathway-specific, not that
uptake caused the sensitivity difference.

### Files saved

- `results/de_results.csv`
- `results/scores.csv`

### Next session — Stage 6, figures

1. Heatmap: 25 genes x 46 lines, annotated by subtype
2. Volcano: logFC vs -log10(adj.P), gene set only, hits labelled
3. Caveolae score by subtype, MCF-7 and MDA-MB-231 marked — **the key figure**
4. Clathrin score by subtype, as the negative contrast

### Still outstanding

- **Email Dr. El-Hadidi** — now overdue, and there's a real result to show
- Git/GitHub — repo still not created, results now unversioned
- Write-up (Stage 7)
