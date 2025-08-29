#!/bin/bash

set -euo pipefail
source $HOME/WCTE_Production/config.sh


for f in ${OUTPUT_PATH}/e-/rootfiles/*.root; do
    BASENAME=$(basename "$f" .root)
    qsub -v BASENAME="$BASENAME",f="$f" -o "$OUT_LOG" -e "$ERR_LOG" $HOME/WCTE_Production/e-/single_root2npz.pbs
done
