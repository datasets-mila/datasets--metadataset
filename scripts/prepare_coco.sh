#!/bin/bash

source scripts/utils.sh echo -n

# Saner programming env: these switches turn some bugs into errors
set -o errexit -o pipefail

# This script is meant to be used with the command 'datalad run'

[[ ! -z $DATASRC && ! -z $SPLITS && ! -z $RECORDS ]] || \
	exit_on_error_code "'DATASRC', 'SPLITS' and 'RECORDS' env vars are required"

mkdir -p "${DATASRC}/mscoco"

unzip -o coco/2017/train2017.zip -d "${DATASRC}/mscoco"
unzip -o coco/2017/annotations/annotations_trainval2017.zip -d "${DATASRC}/mscoco"
mv -t "${DATASRC}/mscoco" "${DATASRC}/mscoco"/annotations/*

pushd meta-dataset
python3 -m meta_dataset.dataset_conversion.convert_datasets_to_records \
	--dataset=mscoco \
	--mscoco_data_root=$DATASRC/mscoco \
	--splits_root=$SPLITS \
	--records_root=$RECORDS
popd
