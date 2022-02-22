#!/bin/bash

source scripts/utils.sh echo -n

# Saner programming env: these switches turn some bugs into errors
set -o errexit -o pipefail

# This script is meant to be used with the command 'datalad run'

[[ ! -z $DATASRC && ! -z $SPLITS && ! -z $RECORDS ]] || \
	exit_on_error_code "'DATASRC', 'SPLITS' and 'RECORDS' env vars are required"

mkdir -p "${DATASRC}/fungi"

tar --overwrite -xzf fgvcxfungi/fungi_train_val.tgz -C "${DATASRC}/fungi"
tar --overwrite -xzf fgvcxfungi/train_val_annotations.tgz -C "${DATASRC}/fungi"

pushd meta-dataset
python3 -m meta_dataset.dataset_conversion.convert_datasets_to_records \
	--dataset=fungi \
	--fungi_data_root=$DATASRC/fungi \
	--splits_root=$SPLITS \
	--records_root=$RECORDS
popd
