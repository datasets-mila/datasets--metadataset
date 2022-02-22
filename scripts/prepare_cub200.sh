#!/bin/bash

source scripts/utils.sh echo -n

# Saner programming env: these switches turn some bugs into errors
set -o errexit -o pipefail

# This script is meant to be used with the command 'datalad run'

[[ ! -z $DATASRC && ! -z $SPLITS && ! -z $RECORDS ]] || \
	exit_on_error_code "'DATASRC', 'SPLITS' and 'RECORDS' env vars are required"

mkdir -p "${DATASRC}/CUB_200_2011"

tar --overwrite -xzf cub200/CUB_200_2011.tgz -C "${DATASRC}"

pushd meta-dataset
python3 -m meta_dataset.dataset_conversion.convert_datasets_to_records \
	--dataset=cu_birds \
	--cu_birds_data_root=$DATASRC/CUB_200_2011 \
	--splits_root=$SPLITS \
	--records_root=$RECORDS
popd
