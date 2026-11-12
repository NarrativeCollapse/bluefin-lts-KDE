#!/usr/bin/env bash

set -xeuo pipefail

# IMAGE_NAME already carries the -nvidia suffix (set by CI / `just build`)
FLAVOR="nvidia"
IMAGE_REF="ostree-image-signed:docker://ghcr.io/${IMAGE_VENDOR}/${IMAGE_NAME}"
export FLAVOR
export IMAGE_NAME
export IMAGE_REF
"${SCRIPTS_PATH}/image-info-set"
