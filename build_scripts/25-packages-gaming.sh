#!/usr/bin/env bash

set -xeuo pipefail

# Gaming support, modelled on Bazzite.
#
# Bazzite installs Steam, Lutris, gamescope and MangoHud as RPMs from Fedora-only
# repositories (RPM Fusion, Terra), which do not exist for CentOS Stream. Here the
# launchers come from Flathub instead (see /usr/share/flatpak/preinstall.d), and
# only the host-side pieces that Flatpak games talk to are installed as RPMs.

# gamemode: the GameMode portal lets Flatpak Steam/Lutris/Heroic use the host's
# gamemoded. The others are useful for native games and tools; whatever EPEL
# does not ship is skipped with a warning in the build log.
/run/context/build_scripts/scripts/dnf-install-available \
	gamemode \
	gamescope \
	mangohud \
	vkBasalt \
	vulkan-tools \
	lm_sensors \
	evtest

# Steam Input / Steam VR udev rules (controllers, headsets) are vendored in
# system_files from ValveSoftware/steam-devices, since Flatpak Steam needs them
# on the host. Fail loudly if they went missing.
test -f /usr/lib/udev/rules.d/60-steam-input.rules
test -f /usr/lib/udev/rules.d/60-steam-vr.rules

# ntsync speeds up Wine/Proton but only exists in kernel 6.14 and newer. The
# CentOS kernel is older, so only autoload it when the module is present.
KERNEL_VERSION="$(rpm -q kernel --queryformat '%{VERSION}-%{RELEASE}.%{ARCH}' | tail -n 1)"
if find "/usr/lib/modules/${KERNEL_VERSION}" -name 'ntsync.ko*' -print -quit | grep -q .; then
	echo "ntsync" >/usr/lib/modules-load.d/ntsync.conf
else
	echo "ntsync module not in kernel ${KERNEL_VERSION}, not autoloading it"
fi
