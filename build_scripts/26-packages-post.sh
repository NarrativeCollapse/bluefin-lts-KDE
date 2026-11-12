#!/usr/bin/env bash

set -xeuo pipefail

# Rebuild gdk-pixbuf loader cache so all installed loaders are registered (GTK apps)
if command -v gdk-pixbuf-query-loaders-64 >/dev/null 2>&1; then
	gdk-pixbuf-query-loaders-64 --update-cache
fi

# Add Flathub by default
mkdir -p /etc/flatpak/remotes.d
curl --retry 3 -o /etc/flatpak/remotes.d/flathub.flatpakrepo "https://dl.flathub.org/repo/flathub.flatpakrepo"

# There is no `-defaults` subpackage on c10s
curl -fsSLo /usr/lib/systemd/zram-generator.conf "https://src.fedoraproject.org/rpms/zram-generator/raw/rawhide/f/zram-generator.conf"
grep -F -e "zram-size =" /usr/lib/systemd/zram-generator.conf

# https://src.fedoraproject.org/rpms/firewalld/blob/rawhide/f/firewalld.spec
curl -fsSLo /usr/lib/firewalld/zones/FedoraWorkstation.xml "https://src.fedoraproject.org/rpms/firewalld/raw/rawhide/f/FedoraWorkstation.xml"
grep -F -e '<port protocol="udp" port="1025-65535"/>' /usr/lib/firewalld/zones/FedoraWorkstation.xml

# https://src.fedoraproject.org/rpms/firewalld/blob/rawhide/f/firewalld.spec#_178
sed -i 's|^DefaultZone=.*|DefaultZone=FedoraWorkstation|g' /etc/firewalld/firewalld.conf
sed -i 's|^IPv6_rpfilter=.*|IPv6_rpfilter=loose|g' /etc/firewalld/firewalld.conf
grep -F -e "DefaultZone=FedoraWorkstation" /etc/firewalld/firewalld.conf
grep -F -e "IPv6_rpfilter=loose" /etc/firewalld/firewalld.conf

depmod -a "$(ls -1 /lib/modules/ | tail -1)"

# Generate initramfs image after installing branding because of Plymouth subpackage
# Add resume module so that hibernation works
echo "add_dracutmodules+=\" resume \"" >/etc/dracut.conf.d/resume.conf
KERNEL_SUFFIX=""
QUALIFIED_KERNEL="$(rpm -qa | grep -P 'kernel-(|'"$KERNEL_SUFFIX"'-)(\d+\.\d+\.\d+)' | sed -E 's/kernel-(|'"$KERNEL_SUFFIX"'-)//' | tail -n 1)"
/usr/bin/dracut --no-hostonly --kver "$QUALIFIED_KERNEL" --reproducible --tmpdir /boot --zstd -v --add ostree -f "/lib/modules/$QUALIFIED_KERNEL/initramfs.img"
