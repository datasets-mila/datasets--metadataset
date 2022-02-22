#!/bin/bash

source scripts/utils.sh echo -n

# Saner programming env: these switches turn some bugs into errors
set -o errexit -o pipefail

# This script is meant to be used with the command 'datalad run'

[[ ! -z $DATASRC && ! -z $SPLITS && ! -z $RECORDS ]] || \
	exit_on_error_code "'DATASRC', 'SPLITS' and 'RECORDS' env vars are required"

mkdir -p "${DATASRC}/ILSVRC2012_img_train"

files_url=(
        "http://www.image-net.org/data/wordnet.is_a.txt ${DATASRC}/ILSVRC2012_img_train/wordnet.is_a.txt"
	"http://www.image-net.org/data/words.txt ${DATASRC}/ILSVRC2012_img_train/words.txt")

git-annex addurl --force --fast -c annex.largefiles=anything --raw --batch --with-files <<EOF
$(for file_url in "${files_url[@]}" ; do echo "${file_url}" ; done)
EOF
git-annex get --fast -J8
git-annex migrate --fast -c annex.largefiles=anything \
	"${DATASRC}/ILSVRC2012_img_train/wordnet.is_a.txt" \
	"${DATASRC}/ILSVRC2012_img_train/words.txt"

tar --overwrite -xf imagenet/ILSVRC2012_img_train.tar -C "${DATASRC}/ILSVRC2012_img_train"

pushd "${DATASRC}/ILSVRC2012_img_train"
for FILE in *.tar
do
	mkdir -p ${FILE/.tar/}
done
mkdir -p .tar && mv -t .tar *.tar
ls -d n* | xargs -n1 -P8 -I__CLS__ tar --overwrite -xf .tar/__CLS__.tar -C __CLS__
mv -t . .tar/*.tar && rm -r .tar
popd

pushd meta-dataset
python3 -m meta_dataset.dataset_conversion.convert_datasets_to_records \
	--dataset=ilsvrc_2012_v2 \
	--ilsvrc_2012_data_root=${DATASRC}/ILSVRC2012_img_train \
	--splits_root=$SPLITS \
	--records_root=$RECORDS
popd
