#!/bin/bash
set -euo pipefail

PBS_SCRIPT="$HOME/Scripts/electron/MC_e.pbs"

for i in {0..9}; do
	echo "Submitting job IDX=$i ..."
	qsub -v IDX=$i "$PBS_SCRIPT"
done
