#!/bin/bash

set -xeuo pipefail

sed -i 's|uupd|& --disable-module-distrobox|' /usr/lib/systemd/system/uupd.service

# Enable sleep then hibernation by DEFAULT!
sed -i 's/#HandleLidSwitch=.*/HandleLidSwitch=suspend-then-hibernate/g' /usr/lib/systemd/logind.conf
sed -i 's/#HandleLidSwitchDocked=.*/HandleLidSwitchDocked=suspend-then-hibernate/g' /usr/lib/systemd/logind.conf
sed -i 's/#HandleLidSwitchExternalPower=.*/HandleLidSwitchExternalPower=suspend-then-hibernate/g' /usr/lib/systemd/logind.conf
sed -i 's/#SleepOperation=.*/SleepOperation=suspend-then-hibernate/g' /usr/lib/systemd/logind.conf
systemctl enable brew-setup.service
systemctl enable sddm.service
systemctl set-default graphical.target
systemctl enable firewalld.service
systemctl enable fwupd.service
systemctl enable flatpak-preinstall.service
systemctl --global enable podman-auto-update.timer
systemctl disable rpm-ostree.service
systemctl disable mcelog.service
systemctl enable tailscaled.service
systemctl enable uupd.timer
systemctl enable ublue-system-setup.service
systemctl --global enable ublue-user-setup.service
systemctl mask bootc-fetch-apply-updates.timer bootc-fetch-apply-updates.service
systemctl disable sshd.service

# projectbluefin/common ships a "countme" ping that reports installs as Bluefin.
# This image is not Bluefin, so do not count it as one.
systemctl mask projectbluefin-countme.timer projectbluefin-countme.service

# Disable lastlog display on previous failed login (This makes logins slow)
authselect enable-feature with-silent-lastlog

# Enable polkit rules for fingerprint sensors via fprintd
authselect enable-feature with-fingerprint

sed -i -e "s@PrivateTmp=.*@PrivateTmp=no@g" /usr/lib/systemd/system/systemd-resolved.service
# FIXME: this does not yet work, the resolution service fails for somer reason
# enable systemd-resolved for proper name resolution
systemctl enable systemd-resolved.service
