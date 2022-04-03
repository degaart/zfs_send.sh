#!/usr/bin/env bash

set -eou pipefail

SRC_DATASET="${1-}"
DST_HOST="${2-}"
DST_DATASET="${3-}"
MBUFFER_PORT=1024

if [ "$DST_DATASET" = "" ]; then
    echo "Usage: $0 <src-dataset> <dst-host> <dst_dataset>"
    exit 1
fi

ssh root@"$DST_HOST" "mbuffer -q -m2G -s256k -I${MBUFFER_PORT}|zfs receive -Fu ${DST_DATASET}" &
zfs destroy -r "${SRC_DATASET}@send" || true
zfs snap "${SRC_DATASET}@send"
zfs send -ec "${SRC_DATASET}@send"|mbuffer -s256k -m2G -O"${DST_HOST}:${MBUFFER_PORT}"

