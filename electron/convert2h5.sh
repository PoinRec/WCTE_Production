#!/bin/bash

set -euo pipefail

mkdir -p ~/Data/MC_e

singularity exec -B ~:/mnt ~/Images/larcv2_ub2204-cuda121-torch251-larndsim-2025-03-20.sif \
	bash -lc "python /mnt/Simulations/DataTools/root_utils/np_to_digihit_array_hdf5.py \
    		/mnt/Simulations/MC_Production/out/npz_events/wcsim_wCDS_e-_Uniform_0_1200MeV_*.npz \
    		-o /mnt/Data/MC_e/wcsim_wCDS_e-_Uniform_0_1200MeV_dighit.h5 \
    		-m 100 -H 135.71175 -R 153.7963"
