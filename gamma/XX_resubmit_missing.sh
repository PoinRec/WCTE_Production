#!/bin/bash
set -euo pipefail

WORKDIR=~/Simulations/MC_Production
SCRIPT="$HOME/Scripts/gamma/MC_gamma.pbs"

cd "$WORKDIR"

echo "[INFO] Scanning for missing output files..."

mapfile -t SH_FILES < <(ls -1 shell/wcsim_wCDS_gamma_Uniform_0_1200MeV_*.sh | sort)

missing_count=0

for idx in "${!SH_FILES[@]}"; do
    filename=$(basename "${SH_FILES[idx]}")
    base=${filename%.sh}
    expected_output=out/${base}.root

    if [ ! -f "$expected_output" ]; then
        echo "[MISSING] $expected_output not found. Resubmitting job IDX=$idx..."
        qsub -v IDX=$idx "$SCRIPT" || echo "[WARNING] Failed to submit job IDX=$idx"
        missing_count=$((missing_count + 1))
    fi
done

echo "[DONE] Resubmitted $missing_count missing jobs."
