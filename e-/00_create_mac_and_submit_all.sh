#!/bin/bash

set -euo pipefail
source $HOME/WCTE_Production/config.sh

cd $MC_PRODUCTION

# default
F=10

while getopts "f:" opt; do
	case $opt in
		f) F=$OPTARG;;
	esac
done

python3 createWCSimFiles.py -p e- -u 0,1200 -n 10000 -f "$F" -s 42

chmod u+x $OUTPUT_PATH/e-/shell/*.sh 



PBS_SCRIPT="$HOME/WCTE_Production/e-/MC_e-.pbs"

for i in $(seq 0 $((F - 1))); do
        echo "Submitting job IDX=$i ..."
        qsub -v IDX=$i -o "$OUT_LOG" -e "$ERR_LOG" "$PBS_SCRIPT"
done
