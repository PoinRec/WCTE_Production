#!/bin/bash

set -euo pipefail
source $HOME/WCTE_Production/config.sh

PBS_SCRIPT="$HOME/WCTE_Production/e-/MC_e-.pbs"

cd "${OUTPUT_PATH}/e-"

echo "[INFO] Scanning for missing output files..."

mapfile -t SH_FILES < <(ls -1 shell/wcsim_wCDS_e-_Uniform_0_1200MeV_*.sh | sort)

missing_count=0

for idx in "${!SH_FILES[@]}"; do
    filename=$(basename "${SH_FILES[idx]}")
    base=${filename%.sh}
    expected_output=rootfiles/${base}.root

    if [ ! -f "$expected_output" ]; then
        echo "[MISSING] $expected_output not found. Resubmitting job IDX=$idx..."
        qsub -v IDX=$idx -o "$OUT_LOG" -e "$ERR_LOG" "$PBS_SCRIPT" || echo "[WARNING] Failed to submit job IDX=$idx"
        missing_count=$((missing_count + 1))
    fi
done

echo "[DONE] Resubmitted $missing_count missing jobs."
