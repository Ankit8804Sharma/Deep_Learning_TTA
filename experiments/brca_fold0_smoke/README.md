# TTA BRCA - Experiment 001

## Date
26 November 2026

## Objective
Verify end-to-end execution of the original TTA
multimodal survival prediction architecture.

## Dataset
TCGA-BRCA
Training patients: 692
Testing patients: 176
Endpoint: Disease-specific survival
Fold: 0
Modalities: Histopathology and transcriptomics

## Hardware
NVIDIA RTX 4060, 8 GB VRAM
WSL Ubuntu 24.04.2
31 GiB system RAM

## Configuration
Epochs: 2
Batch size: 32
Bag size: 4096
Shared prototypes: 32
Prototype dimension: 256
Optimizer: AdamW
Learning rate: 0.0001
Weight decay: 0.00001
Seed: 1
DataLoader workers: 2
Warmup epochs: 0
Early stopping: Disabled
Loss: Cox survival loss

## Implementation changes
- Added separate smoke-test training script.
- Enabled batch-level training progress.
- Reduced DataLoader workers from 8 to 2 after
  a multiprocessing ancillary-data transfer error.
- Retained original architecture, batch and bag sizes.

## Results
Initial batch loss: 5.6716
Final epoch average loss: 2.7424
Final epoch survival loss: 1.3561
Test C-index: 0.6752577319587629
Test loss: 20.00971031188965
Test survival loss: 20.00971031188965
Selected WSI Sinkhorn head: 0
Selected omics Sinkhorn head: 4

## Outcome
Training and both train/test evaluations completed.
Model checkpoint and experiment outputs were saved.

## Limitations
This is a two-epoch, single-fold smoke test,
not a complete reproduction of published results.
Warmup and early stopping differ from the
original training configuration.
Full five-fold evaluation remains pending.
Test loss aggregation requires further analysis.

## Version Control
Original baseline: 8d1066e
Implementation commit: 48c3263

## Recovery
Checkpoint, configuration, prediction dumps,
training logs and evaluation metrics are backed
up separately on the D drive.
