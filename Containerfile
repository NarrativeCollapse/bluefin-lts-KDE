ARG MAJOR_VERSION="${MAJOR_VERSION:-c10s}"
ARG BASE_IMAGE_SHA="${BASE_IMAGE_SHA:-sha256-feea845d2e245b5e125181764cfbc26b6dacfb3124f9c8d6a2aaa4a3f91082ed}"
ARG ENABLE_HWE="${ENABLE_HWE:-1}"
ARG AKMODS_VERSION="${AKMODS_VERSION:-coreos-stable-43}"
ARG COMMON_IMAGE_REF
ARG BREW_IMAGE_REF
# The akmods-zfs image is only used as the source of the signed kernel RPMs
# (/kernel-rpms); it is the akmods image that is published for both the
# centos-10 and coreos-stable (HWE) kernels. ZFS itself is not installed.
FROM ghcr.io/ublue-os/akmods-zfs:${AKMODS_VERSION} AS akmods_kernel
FROM ghcr.io/ublue-os/akmods-nvidia-open:${AKMODS_VERSION} AS akmods_nvidia_open
FROM ${COMMON_IMAGE_REF} AS common
FROM ${BREW_IMAGE_REF} AS brew
FROM scratch AS context

# Order matters: later copies win. Only the desktop-agnostic "shared" part of
# projectbluefin/common is used (setup hooks, ujust, uupd, container policy);
# its GNOME-specific "bluefin" part is not. This repo's own files go last so
# they can override anything from common.
COPY --from=brew /system_files /files
COPY --from=common /system_files/shared /files
COPY system_files /files
COPY system_files_overrides /overrides
COPY build_scripts /build_scripts

ARG MAJOR_VERSION="${MAJOR_VERSION:-c10s}"
FROM quay.io/centos-bootc/centos-bootc:$MAJOR_VERSION

ARG ENABLE_HWE="${ENABLE_HWE:-1}"
ARG ENABLE_NVIDIA="${ENABLE_NVIDIA:-0}"
ARG IMAGE_NAME="${IMAGE_NAME:-bluefin-lts-kde}"
ARG IMAGE_VENDOR="${IMAGE_VENDOR:-narrativecollapse}"
ARG MAJOR_VERSION="${MAJOR_VERSION:-lts}"
ARG SHA_HEAD_SHORT="${SHA_HEAD_SHORT:-deadbeef}"

RUN --mount=type=tmpfs,dst=/opt \
  --mount=type=tmpfs,dst=/tmp \
  --mount=type=tmpfs,dst=/var \
  --mount=type=tmpfs,dst=/boot \
  --mount=type=bind,from=akmods_kernel,src=/kernel-rpms,dst=/tmp/kernel-rpms \
  --mount=type=bind,from=akmods_nvidia_open,src=/rpms,dst=/tmp/akmods-nvidia-open-rpms \
  --mount=type=bind,from=context,source=/,target=/run/context \
  /run/context/build_scripts/build.sh

# Makes `/opt` writeable by default
# Needs to be here to make the main image build strict (no /opt there)
RUN rm -rf /opt && ln -s /var/opt /opt
