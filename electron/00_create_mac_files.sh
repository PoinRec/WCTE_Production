#!/bin/bash
set -euo pipefail

cd ~/Simulations/MC_Production

python3 createWCSimFiles.py -p e- -u 0,1200 -n 1000 -f 10 -s 42

chmod u+x ./shell/*.sh 
