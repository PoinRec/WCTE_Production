#!/bin/bash

set -euo pipefail
source $HOME/WCTE_Production/config.sh

singularity exec -B "$HOME":"$HOME" \
	-B "$MYLUSTRE":"$MYLUSTRE" \
	"$IMAGE_H5" \
	bash -lc "
		python $DATATOOLS/root_utils/merge_h5.py \
      		$OUTPUT_PATH/e-/wcsim_wCDS_e-_Uniform_0_1200MeV_dighit.h5 \
      		$OUTPUT_PATH/gamma/wcsim_wCDS_gamma_Uniform_0_1200MeV_dighit.h5 \
      		-o $OUTPUT_PATH/$FILENAME
  		"
