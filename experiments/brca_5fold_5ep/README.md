# TTA BRCA Five-Fold Reproduction

## Status

Completed successfully on November 27, 2026.

## Experimental configuration

- Dataset: TCGA-BRCA
- Patients: 868
- Modalities: Histopathology and transcriptomics
- Pathology encoder: UNI
- Pathology feature dimension: 1024
- Fused representation dimension: 512
- Cross-validation folds: 5
- Epochs per fold: 5
- Warmup epochs: 2
- Batch size: 32
- WSI bag size: 4096
- Shared prototypes: 32
- Optimizer: AdamW
- Learning rate: 0.0001
- DataLoader workers: 2
- Hardware: NVIDIA RTX 4060 8 GB
- Training implementation commit: 3908a74

## Results

| Fold | Test C-index | Test Cox loss |
|---|---:|---:|
| 0 | 0.7250859107 | 6.5705971718 |
| 1 | 0.6244665718 | 7.6566295624 |
| 2 | 0.8068601583 | 5.3264746666 |
| 3 | 0.5660792952 | 4.0475411415 |
| 4 | 0.6945925362 | 5.4862022400 |

Mean C-index: 0.6834168944260278
Sample standard deviation: 0.09265890947041087
Population standard deviation: 0.0828766481187351

Final result: 0.6834 +/- 0.0927 (sample SD)

## Verification

- All five folds completed successfully.
- All five trained model checkpoints saved.
- All five prediction dumps saved.
- All five fused representation dumps saved.
- All inspected numerical values are finite.
- Train-test sample ID overlap is zero for every fold.
- Mean and standard deviation independently recalculated.
- Complete 85 MB experimental backup created.

## Limitations

This is a resource-constrained reproduction, not an
exact replication of the published 30-epoch protocol.

Differences include reduced training duration, adapted
warmup, disabled early stopping due to missing validation
splits, reduced DataLoader workers, RNA feature-count
discrepancy and correction of the final Cox evaluation loss.

The original architecture and training objectives were retained.

## Local backup

/mnt/d/TTA_Data/Recovery/BRCA_5Fold_Completed

Patient-level data, prediction dumps and model checkpoints
are retained locally rather than uploaded to the public
GitHub repository.
