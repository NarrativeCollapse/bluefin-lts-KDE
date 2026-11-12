#!/usr/bin/env bash

set -xeuo pipefail

# This is the base for a minimal KDE Plasma system on CentOS Stream.
# Plasma comes from EPEL, which is maintained by the Fedora KDE SIG.

# This thing slows down downloads A LOT for no reason
dnf remove -y subscription-manager
dnf -y install 'dnf-command(versionlock)'

/run/context/build_scripts/scripts/kernel-swap.sh

# This fixes a lot of skew issues on the Nvidia variant because kernel-devel wont update then
dnf versionlock add kernel kernel-devel kernel-devel-matched kernel-core kernel-modules kernel-modules-core kernel-modules-extra kernel-uki-virt

dnf -y install "https://dl.fedoraproject.org/pub/epel/epel-release-latest-${MAJOR_VERSION_NUMBER}.noarch.rpm"
dnf config-manager --set-enabled crb

# Multimedia codecs
dnf config-manager --add-repo=https://negativo17.org/repos/epel-multimedia.repo
dnf config-manager --set-disabled epel-multimedia
dnf -y install --enablerepo=epel-multimedia \
	ffmpeg libavcodec @multimedia gstreamer1-plugins-{bad-free,bad-free-libs,good,base} lame{,-libs} libjxl ffmpegthumbnailer

# `dnf group info Workstation` without the desktop environment
dnf group install -y --nobest \
	-x rsyslog* \
	-x cockpit \
	-x cronie* \
	-x crontabs \
	-x PackageKit \
	-x PackageKit-command-not-found \
	"Common NetworkManager submodules" \
	"Core" \
	"Fonts" \
	"Guest Desktop Agents" \
	"Hardware Support" \
	"Printing Client" \
	"Standard" \
	"Workstation product core"

# Minimal Plasma desktop. These are required: the build fails if any is missing.
dnf -y install \
	-x PackageKit \
	-x PackageKit-command-not-found \
	-x plasma-discover-packagekit \
	dolphin \
	konsole \
	kscreen \
	kwin \
	plasma-desktop \
	plasma-nm \
	plasma-pa \
	plasma-systemsettings \
	plasma-workspace \
	powerdevil \
	sddm \
	xdg-desktop-portal-kde

# The rest of a usable Plasma desktop. Package splits differ between Fedora and
# EPEL releases, so anything missing here is skipped with a warning in the log.
/run/context/build_scripts/scripts/dnf-install-available \
	ark \
	bluedevil \
	breeze-gtk \
	breeze-icon-theme \
	ffmpegthumbs \
	filelight \
	gwenview \
	kde-connect \
	kde-gtk-config \
	kdegraphics-thumbnailers \
	kdeplasma-addons \
	kf6-kimageformats \
	kinfocenter \
	kio-admin \
	kio-extras \
	kmenuedit \
	kwrite \
	okular \
	orca \
	pam-kwallet \
	plasma-breeze \
	plasma-browser-integration \
	plasma-disks \
	plasma-firewall-firewalld \
	plasma-systemmonitor \
	plasma-thunderbolt \
	plasma-workspace-wayland \
	polkit-kde \
	print-manager \
	sddm-breeze \
	sddm-kcm \
	sddm-wayland-plasma \
	spectacle \
	xdg-user-dirs \
	NetworkManager-adsl \
	libsane-hpaio \
	sane-backends-drivers-scanners

# Fail early with a clear message if Plasma did not end up usable
for required in /usr/bin/startplasma-wayland /usr/bin/kwin_wayland /usr/bin/sddm /usr/share/wayland-sessions/plasma.desktop; do
	if [[ ! -e "${required}" ]]; then
		echo "FATAL: ${required} is missing, the Plasma install is incomplete"
		exit 1
	fi
done

dnf -y install \
	plymouth \
	plymouth-system-theme \
	fwupd \
	systemd-{resolved,container,oomd} \
	libcamera{,-{v4l2,gstreamer,tools}}

# This package adds "[systemd] Failed Units: *" to the bashrc startup
dnf -y remove console-login-helper-messages
