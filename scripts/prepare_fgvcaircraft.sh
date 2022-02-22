#!/bin/bash

source scripts/utils.sh echo -n

# Saner programming env: these switches turn some bugs into errors
set -o errexit -o pipefail

# This script is meant to be used with the command 'datalad run'

[[ ! -z $DATASRC && ! -z $SPLITS && ! -z $RECORDS ]] || \
	exit_on_error_code "'DATASRC', 'SPLITS' and 'RECORDS' env vars are required"

mkdir -p "${DATASRC}/fgvc-aircraft-2013b"

tar --overwrite -xzf fgvcaircraft/fgvc-aircraft-2013b.tar.gz -C "${DATASRC}"

pushd meta-dataset
python3 -m meta_dataset.dataset_conversion.convert_datasets_to_records \
	--dataset=aircraft \
	--aircraft_data_root=$DATASRC/fgvc-aircraft-2013b \
	--splits_root=$SPLITS \
	--records_root=$RECORDS
popd
