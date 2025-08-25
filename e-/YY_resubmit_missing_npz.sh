#!/bin/bash

set -euo pipefail
source $HOME/WCTE_Production/config.sh

PBS_SCRIPT="$HOME/WCTE_Production/e-/single_root2npz.pbs"
ROOT_DIR="${OUTPUT_PATH}/e-/rootfiles"
NPZ_DIR="${OUTPUT_PATH}/e-/npzfiles"

echo "[INFO] Scanning for missing .npz files..."

mkdir -p "$NPZ_DIR"

missing_count=0

for f in "${ROOT_DIR}"/*.root; do
    BASENAME=$(basename "$f" .root)
    expected_output="${NPZ_DIR}/${BASENAME}.npz"

    if [ ! -f "$expected_output" ]; then
        echo "[MISSING] $expected_output not found. Resubmitting job for $BASENAME..."
        qsub -v BASENAME="$BASENAME",f="$f" -o "$OUT_LOG" -e "$ERR_LOG" "$PBS_SCRIPT" || \
            echo "[WARNING] Failed to submit job for $BASENAME"
        missing_count=$((missing_count + 1))
    fi
done

echo "[DONE] Resubmitted $missing_count missing .npz jobs."
