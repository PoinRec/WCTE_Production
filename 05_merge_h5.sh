#!/bin/bash

set -euo pipefail

singularity exec -B ~:/mnt ~/Images/larcv2_ub2204-cuda121-torch251-larndsim-2025-03-20.sif \
        bash -lc 'python /mnt/Simulations/DataTools/root_utils/merge_h5.py /mnt/Data/MC_e/wcsim_wCDS_e-_Uniform_0_1200MeV_dighit.h5 /mnt/Data/MC_gamma/wcsim_wCDS_gamma_Uniform_0_1200MeV_dighit.h5 -o /mnt/Data/wcsim_wCDS_e-_gamma_Uniform_0_1200MeV_dighit.h5'
