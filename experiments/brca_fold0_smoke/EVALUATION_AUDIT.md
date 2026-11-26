# TTA Evaluation Audit

Date: 26 November 2026
Experiment: TCGA-BRCA Fold 0

## Issue 1: Cox Evaluation Loss

The validation function collects model logits
directly when CoxLoss is used.

However, the final loss recomputation incorrectly
assumes these values are exponentiated risks.

The code clamps the logits and applies a logarithm,
distorting the original model outputs.

## Correction

Pass the collected logits directly to CoxLoss
without clamping or applying another logarithm.

## Experimental Verification

Original evaluation loss: 20.00971031188965
Corrected evaluation loss: 4.217566967010498

No retraining was performed.
Model weights and predictions remain unchanged.

## C-index Verification

Original C-index: 0.6752577319587629
Independently verified C-index: 0.6752577319587629

Concordant pairs: 393
Discordant pairs: 189
Tied risk pairs: 0
Tied time pairs: 0
Comparable pairs: 582

C-index = 393 / 582

## Test Cohort

Total patients: 176
Observed DSS events: 8
Censored patients: 168

Censoring percentage: 95.4545%

## Prediction Statistics

Minimum log-risk: -3.284092664718628
Maximum log-risk: 1.8268908262252808
Mean log-risk: -0.6233792052265595
Median log-risk: -0.6418988406658173
Standard deviation: 1.063326778173353

Negative logits: 130
Positive logits: 46
Zero logits: 0

## Issue 2: Serialization Format

The file all_dumps.h5 is actually serialized
using Python pickle through save_pkl().

Loading the file with pickle.load() succeeds.

Training fused representation: 692 x 512
Testing fused representation: 176 x 512

## Scientific Interpretation

The loss correction does not improve predictive
performance. It corrects the evaluation calculation.

The reported C-index is unaffected because it is
computed before the incorrect loss transformation.

The small number of observed DSS events limits
the strength of statistical conclusions.

This remains a single-fold, two-epoch smoke test,
not a full reproduction of the published results.
