#!/bin/bash

source scripts/utils.sh echo -n

# Saner programming env: these switches turn some bugs into errors
set -o errexit -o pipefail

# This script is meant to be used with the command 'datalad run'

[[ ! -z $DATASRC && ! -z $SPLITS && ! -z $RECORDS ]] || \
	exit_on_error_code "'DATASRC', 'SPLITS' and 'RECORDS' env vars are required"

mkdir -p "${DATASRC}/quickdraw"

pushd "${DATASRC}/quickdraw"
ln -sft "$PWD" "$(realpath --relative-to="$PWD" "$(dirs +1)"/quickdraw/numpy_bitmap)"/*
popd

pushd meta-dataset
python3 -m meta_dataset.dataset_conversion.convert_datasets_to_records \
	--dataset=quickdraw \
	--quickdraw_data_root=$DATASRC/quickdraw \
	--splits_root=$SPLITS \
	--records_root=$RECORDS
popd
