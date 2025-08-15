#!/bin/bash
set -euo pipefail

cd ~/Simulations/MC_Production

event_id=${1:-42}

singularity exec -B ./:/mnt ~/Images/softwarecontainer_workshop.sif \
	bash -lc 'source /opt/entrypoint.sh && \
   		root -l -b -q "/mnt/validation/EventDisplay.c(\"/mnt/out/wcsim_wCDS_e-_Uniform_0_1200MeV_*.root\")"'


singularity exec -B ./:/mnt ~/Images/softwarecontainer_workshop.sif \
	bash -lc 'source /opt/entrypoint.sh && \
            	root -l -b -q "/mnt/validation/VertexDistribution.c(\"/mnt/out/wcsim_wCDS_e-_Uniform_0_1200MeV_*.root\")"'


singularity exec -B ./:/mnt ~/Images/softwarecontainer_v1.4.0.sif \
  	bash -lc 'source /opt/WCSim/build/this_wcsim.sh && \
	    	root -l -b -q "/mnt/validation/EventDisplay_SingleEvent.c(\"/mnt/out/wcsim_wCDS_e-_Uniform_0_1200MeV_*.root\", '"${event_id}"')"' 
