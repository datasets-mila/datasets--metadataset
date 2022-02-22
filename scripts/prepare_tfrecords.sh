#!/bin/bash

source scripts/utils.sh echo -n

# Saner programming env: these switches turn some bugs into errors
set -o errexit -o pipefail

# This script is meant to be used with the command 'datalad run'

function killtree {
	local _pid=$1
	local _sig=${2:-TERM}
	local _childs=($(ps -o pid --no-headers --ppid ${_pid}))
	! kill -stop -p ${_childs[@]} &> /dev/null # needed to stop quickly forking parent from producing children between child killing and parent killing
	for _child in ${_childs[@]}
	do
		if ps -p ${_child} > /dev/null
		then
			killtree ${_child} ${_sig}
			kill -${_sig} ${_child}
			kill -cont ${_child}
		fi
	done
}

python3 -m pip install "tensorflow-gpu==2.3.*" -r meta-dataset/requirements.txt || \
	exit_on_error_code "Failed to install requirements: pip install"

export DATASRC=$PWD/datasrc
export SPLITS=$PWD/splits
export RECORDS=$PWD/records

mkdir -p logs/ "${DATASRC}" "${SPLITS}" "${RECORDS}"

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

trap 'killtree $$' EXIT SIGINT SIGTERM

for d in "${_datasets[@]}"
do
	scripts/prepare_${d}.sh &> logs/prepare_${d}.out &
done

for jid in $(jobs -rp)
do
	wait $jid
done

./scripts/stats.sh records/*/

for d in "${_datasets[@]}"
do
	git rm -f ${d}/
done
