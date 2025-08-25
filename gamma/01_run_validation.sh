#!/bin/bash

set -euo pipefail
source $HOME/WCTE_Production/config.sh

event_id="${1:-42}"

qsub -v EVENT_ID=$event_id -o "$OUT_LOG" -e "$ERR_LOG" validation.pbs
