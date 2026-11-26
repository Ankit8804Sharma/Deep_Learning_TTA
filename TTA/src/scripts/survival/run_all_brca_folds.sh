#!/usr/bin/env bash

set -euo pipefail

cd "$(dirname "$(realpath "$0")")/../.."

MODE="${1:-5ep}"
START_FOLD="${2:-0}"
END_FOLD="${3:-4}"

DATA_ROOT="${TTA_DATA_ROOT:-/mnt/d/TTA_Data/tcga_brca_uni/}"

case "$MODE" in

    5ep)
        TRAIN_SCRIPT="scripts/survival/tta_reproduction_5ep.sh"
        RESULT_ROOT="results_reproduction_5ep"
        EPOCHS=5
        WARMUP=2
        ;;

    30ep)
        TRAIN_SCRIPT="scripts/survival/tta_reproduction.sh"
        RESULT_ROOT="results_reproduction"
        EPOCHS=30
        WARMUP=15
        ;;

    *)
        echo "Usage: $0 {5ep|30ep} [start_fold] [end_fold]"
        exit 1
        ;;

esac

if ! [[ "$START_FOLD" =~ ^[0-4]$ &&
        "$END_FOLD" =~ ^[0-4]$ ]] ||
        (( START_FOLD > END_FOLD )); then
    echo "Invalid fold range."
    exit 1
fi

mkdir -p logs "$RESULT_ROOT"

export PYTHONUNBUFFERED=1
export WARMUP_EPOCHS_OVERRIDE="$WARMUP"

ulimit -Sn 65536 || true

FEATURE_DIR="${DATA_ROOT%/}/extracted_mag20x_patch256_fp/uni/feats_h5"

if [[ ! -d "$FEATURE_DIR" ]]; then
    echo "ERROR: Feature directory missing:"
    echo "$FEATURE_DIR"
    exit 1
fi

SESSION=$(date +%Y%m%d_%H%M%S)

echo "=========================================="
echo "TTA BRCA FIVE-FOLD EXPERIMENT"
echo "Computer: $(hostname)"
echo "Git commit: $(git rev-parse --short HEAD)"
echo "Mode: $MODE"
echo "Epochs: $EPOCHS"
echo "Warmup: $WARMUP"
echo "Batch size: 32"
echo "Bag size: 4096"
echo "DataLoader workers: 2"
echo "Fold range: $START_FOLD to $END_FOLD"
echo "Data root: $DATA_ROOT"
echo "Started: $(date)"
echo "=========================================="

for ((fold=START_FOLD; fold<=END_FOLD; fold++)); do

    SPLIT_DIR="survival/TCGA_BRCA_overall_survival_k=${fold}"

    for split in train test; do
        if [[ ! -s "splits/$SPLIT_DIR/$split.csv" ]]; then
            echo "ERROR: Missing split $split for fold $fold"
            exit 1
        fi
    done

    FOLD_LOG="logs/brca_${MODE}_fold${fold}_${SESSION}.log"

    MARKER=$(mktemp)

    echo ""
    echo "=========================================="
    echo "STARTING FOLD $fold"
    echo "Mode: $MODE"
    echo "Time: $(date)"
    echo "=========================================="

    if bash "$TRAIN_SCRIPT" \
        "$fold" \
        BRCA_uni_survival \
        dss_survival_days \
        "$SPLIT_DIR" \
        train,test \
        "$DATA_ROOT" \
        2>&1 | tee "$FOLD_LOG"
    then

        SUMMARY=$(find "$RESULT_ROOT" \
            -type f \
            -path "*/k=${fold}/*/summary.csv" \
            -newer "$MARKER" \
            -print -quit)

        rm -f "$MARKER"

        if [[ -z "$SUMMARY" ]]; then
            echo "ERROR: No new summary.csv for fold $fold"
            exit 1
        fi

        python - "$SUMMARY" <<'PY'
import csv
import math
import sys

with open(sys.argv[1], newline="") as f:
    rows = list(csv.DictReader(f))

assert len(rows) == 1

score = float(rows[0]["c_index_test"])

assert math.isfinite(score)
assert 0 <= score <= 1

print("Verified test C-index:", score)
PY

        echo "FOLD $fold COMPLETED SUCCESSFULLY"
        echo "Completed: $(date)"
        echo "Summary: $SUMMARY"

        cat "$SUMMARY"

    else

        rm -f "$MARKER"

        echo "ERROR: Fold $fold failed."
        echo "Check log: $FOLD_LOG"
        echo "Remaining folds stopped."

        exit 1

    fi

done

echo ""
echo "=========================================="
echo "ALL REQUESTED FOLDS COMPLETED"
echo "Mode: $MODE"
echo "Finished: $(date)"
echo "=========================================="
