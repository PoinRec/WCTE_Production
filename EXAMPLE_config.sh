#!/bin/bash

# Image Used
export IMAGE_SIM="/home/zhihao/Images/softwarecontainer_workshop.sif"
export IMAGE_H5="/home/zhihao/Images/larcv2_ub2204-cuda121-torch251-larndsim-2025-03-20.sif"

# Your lustre
export MYLUSTRE="/lustre/work/zhihao"

# Output file path
export OUTPUT_PATH="/lustre/work/zhihao/Data/0002_10mil_e-_10mil_gamma_production_20250821"

# Log path
export OUT_LOG="/home/zhihao/Logs/Outputs"
export ERR_LOG="/home/zhihao/Logs/Errors"

# Ouput .h5 filename
export FILENAME="wcsim_wCDS_10mil_e-_10mil_gamma_Uniform_0_1200MeV_dighit.h5"

# Some Repos needed
export DATATOOLS="/home/zhihao/Simulations/DataTools"
export MC_PRODUCTION="/home/zhihao/Simulations/MC_Production"

# Others
export NO_MNT=TRUE
