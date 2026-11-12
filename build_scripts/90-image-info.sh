#!/usr/bin/env bash

set -xeuo pipefail

IMAGE_REF="ostree-image-signed:docker://ghcr.io/${IMAGE_VENDOR}/${IMAGE_NAME}"
IMAGE_INFO="/usr/share/ublue-os/image-info.json"
IMAGE_FLAVOR="main"
IMAGE_TAG="lts"
if [ "${ENABLE_HWE}" == "1" ]; then
	IMAGE_TAG="${IMAGE_TAG}-hwe"
fi

tee "$IMAGE_INFO" <<EOF
{
  "image-name": "${IMAGE_NAME}",
  "image-ref": "${IMAGE_REF}",
  "image-flavor": "${IMAGE_FLAVOR}",
  "image-vendor": "${IMAGE_VENDOR}",
  "image-tag": "${IMAGE_TAG}",
  "centos-version": "${MAJOR_VERSION_NUMBER}"
}
EOF
chmod 0644 "${IMAGE_INFO}"

IMAGE_PRETTY_NAME="Bluefin LTS KDE"
REPO_URL="https://github.com/${IMAGE_VENDOR}/bluefin-lts-kde"
HOME_URL="${REPO_URL}"
DOCUMENTATION_URL="${REPO_URL}#readme"
SUPPORT_URL="${REPO_URL}/issues/"
BUG_SUPPORT_URL="${REPO_URL}/issues/"

# OS Release File (changed in order with upstream)
sed -i -f - /usr/lib/os-release <<EOF
s/^NAME=.*/NAME=\"${IMAGE_PRETTY_NAME}\"/
s/^VARIANT_ID=.*/VARIANT_ID=${IMAGE_NAME}/
s/^PRETTY_NAME=.*/PRETTY_NAME=\"${IMAGE_PRETTY_NAME}\"/
s|^HOME_URL=.*|HOME_URL=\"${HOME_URL}\"|
s|^BUG_REPORT_URL=.*|BUG_REPORT_URL=\"${BUG_SUPPORT_URL}\"|
s|^CPE_NAME=\"cpe:/o:centos:centos|CPE_NAME=\"cpe:/o:${IMAGE_VENDOR}:bluefin-lts-kde|

/^REDHAT_BUGZILLA_PRODUCT=/d
/^REDHAT_BUGZILLA_PRODUCT_VERSION=/d
/^REDHAT_SUPPORT_PRODUCT=/d
/^REDHAT_SUPPORT_PRODUCT_VERSION=/d
EOF

tee -a /usr/lib/os-release <<EOF
DOCUMENTATION_URL="${DOCUMENTATION_URL}"
SUPPORT_URL="${SUPPORT_URL}"
DEFAULT_HOSTNAME="bluefin-kde"
BUILD_ID="${SHA_HEAD_SHORT:-deadbeef}"
EOF
