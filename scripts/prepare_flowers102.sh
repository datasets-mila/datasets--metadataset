#!/bin/bash

source scripts/utils.sh echo -n

# Saner programming env: these switches turn some bugs into errors
set -o errexit -o pipefail

# This script is meant to be used with the command 'datalad run'

[[ ! -z $DATASRC && ! -z $SPLITS && ! -z $RECORDS ]] || \
	exit_on_error_code "'DATASRC', 'SPLITS' and 'RECORDS' env vars are required"

mkdir -p "${DATASRC}/vgg_flower"

tar --overwrite -xzf flowers102/102flowers.tgz -C "${DATASRC}/vgg_flower"
ln -sf "$PWD/flowers102/imagelabels.mat" "${DATASRC}/vgg_flower"

pushd meta-dataset
python3 -m meta_dataset.dataset_conversion.convert_datasets_to_records \
	--dataset=vgg_flower \
	--vgg_flower_data_root=$DATASRC/vgg_flower \
	--splits_root=$SPLITS \
	--records_root=$RECORDS
popd
