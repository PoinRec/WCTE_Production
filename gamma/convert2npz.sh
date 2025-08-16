#!/bin/bash

set -euo pipefail

singularity exec -B ~:/mnt ~/Images/softwarecontainer_workshop.sif bash -lc '
	source /opt/entrypoint.sh
	export PYTHONPATH=/mnt/Simulations/DataTools:$PYTHONPATH

  	mkdir -p /mnt/Simulations/MC_Production/out/npz_events
  	mkdir -p /mnt/Data/MC_gamma

  	for f in /mnt/Simulations/MC_Production/out/wcsim_wCDS_gamma_Uniform_0_1200MeV_*.root; do
    		echo "Converting: $f"
    		python /mnt/Simulations/DataTools/root_utils/event_dump.py "$f" -d /mnt/Simulations/MC_Production/out/npz_events
  	done

  	python /mnt/Simulations/DataTools/root_utils/full_geo_dump.py \
    		/mnt/Simulations/MC_Production/out/wcsim_wCDS_gamma_Uniform_0_1200MeV_0000.root \
    		/mnt/Data/MC_gamma/wcte_geometry.npz
'
