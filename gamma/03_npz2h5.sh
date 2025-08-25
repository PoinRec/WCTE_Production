#!/bin/bash

set -euo pipefail
source $HOME/WCTE_Production/config.sh

qsub -o "$OUT_LOG" -e "$ERR_LOG" merge_npz2h5.pbs 
