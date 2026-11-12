#!/bin/bash

set -xeuo pipefail

dnf -y remove \
	setroubleshoot

dnf -y install \
	btrfs-progs \
	buildah \
	containerd \
	ddcutil \
	distrobox \
	fastfetch \
	firewalld \
	flatpak \
	fpaste \
	fzf \
	glow \
	gum \
	hplip \
	jetbrains-mono-fonts-all \
	jxl-pixbuf-loader \
	just \
	nss-mdns \
	ntfs-3g \
	pcsc-lite \
	powertop \
	rclone \
	restic \
	system-reinstall-bootc \
	tuned-ppd \
	wireguard-tools \
	wl-clipboard \
	xdg-terminal-exec \
	xhost
rm -rf /usr/share/doc/just

# KDE frontends for VPNs and disk management
/run/context/build_scripts/scripts/dnf-install-available \
	kde-partitionmanager \
	plasma-nm-openconnect \
	plasma-nm-openvpn

# Everything that depends on external repositories should be after this.
# Make sure to set them as disabled and enable them only when you are going to use their packages.
# We do, however, leave crb and EPEL enabled by default.

dnf config-manager --add-repo "https://pkgs.tailscale.com/stable/centos/${MAJOR_VERSION_NUMBER}/tailscale.repo"
dnf config-manager --set-disabled "tailscale-stable"
# FIXME: tailscale EPEL10 request: https://bugzilla.redhat.com/show_bug.cgi?id=2349099
dnf -y --enablerepo "tailscale-stable" install \
	tailscale

dnf -y copr enable ublue-os/packages "epel-10-$(arch)"
dnf -y --setopt=retries=5 install uupd
dnf -y copr disable ublue-os/packages

dnf -y copr enable che/nerd-fonts "centos-stream-${MAJOR_VERSION_NUMBER}-$(arch)"
dnf -y copr disable che/nerd-fonts
dnf -y --enablerepo "copr:copr.fedorainfracloud.org:che:nerd-fonts" install \
	nerd-fonts

# This is required so homebrew works indefinitely.
# Symlinking it makes it so whenever another GCC version gets released it will break if the user has updated it without-
# the homebrew package getting updated through our builds.
# We could get some kind of static binary for GCC but this is the cleanest and most tested alternative. This Sucks.
dnf -y --setopt=install_weak_deps=False install gcc
