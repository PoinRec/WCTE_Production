#!/bin/bash
set -euo pipefail

cd ~/Simulations/MC_Production

# default
F=10

while getopts "f:" opt; do
	case $opt in
		f) F=$OPTARG;;
	esac
done

python3 createWCSimFiles.py -p gamma -u 0,1200 -n 10000 -f "$F" -s 42

chmod u+x ./shell/*.sh 



PBS_SCRIPT="$HOME/Scripts/gamma/MC_gamma.pbs"

for i in $(seq 0 $((F - 1))); do
        echo "Submitting job IDX=$i ..."
        qsub -v IDX=$i "$PBS_SCRIPT"
done
