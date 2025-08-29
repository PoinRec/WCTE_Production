#!/bin/bash

set -euo pipefail
source $HOME/WCTE_Production/config.sh


for f in ${OUTPUT_PATH}/gamma/rootfiles/*.root; do
    BASENAME=$(basename "$f" .root)
    qsub -v BASENAME="$BASENAME",f="$f" -o "$OUT_LOG" -e "$ERR_LOG" $HOME/WCTE_Production/gamma/single_root2npz.pbs
done
