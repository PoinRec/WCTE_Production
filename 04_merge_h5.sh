#!/bin/bash

set -euo pipefail
source $HOME/WCTE_Production/config.sh

qsub -o "$OUT_LOG" -e "$ERR_LOG" $HOME/WCTE_Production/merge_h5.pbs
