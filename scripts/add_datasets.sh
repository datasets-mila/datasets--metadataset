#!/bin/bash

source scripts/utils.sh echo -n

# Saner programming env: these switches turn some bugs into errors
set -o errexit -o pipefail

# This script is meant to be used with the command 'datalad run'

_datasets_root=..

_datasets=(
	imagenet
	omniglot
	fgvcaircraft
	cub200
	dtd
	quickdraw
	fgvcxfungi
	flowers102
	gtsrb
	coco)

for d in "${_datasets[@]}"
do
	[[ -d "${d}" ]] || git submodule add -- "${_datasets_root}"/"${d}"
done
