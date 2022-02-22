#!/bin/bash

source scripts/utils.sh echo -n

# Saner programming env: these switches turn some bugs into errors
set -o errexit -o pipefail

# This script is meant to be used with the command 'datalad run'

[[ ! -z $DATASRC && ! -z $SPLITS && ! -z $RECORDS ]] || \
	exit_on_error_code "'DATASRC', 'SPLITS' and 'RECORDS' env vars are required"

mkdir -p "${DATASRC}"

unzip -o gtsrb/GTSRB_Final_Training_Images.zip -d "${DATASRC}"

pushd meta-dataset
python3 -m meta_dataset.dataset_conversion.convert_datasets_to_records \
	--dataset=traffic_sign \
	--traffic_sign_data_root=$DATASRC/GTSRB \
	--splits_root=$SPLITS \
	--records_root=$RECORDS
popd
