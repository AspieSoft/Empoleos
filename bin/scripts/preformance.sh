#!/bin/bash

# install preload
sudo dnf -y copr enable elxreno/preload
sudo dnf -y install preload
sudo systemctl start preload
sudo systemctl enable preload

# install tlp
sudo dnf -y install tlp-rdw
sudo systemctl start tlp
sudo systemctl enable tlp
sudo tlp start

# install thermald
sudo dnf -y install thermald
sudo systemctl start thermald
sudo systemctl enable thermald


#sudo dnf -y install gnome-power-manager power-profiles-daemon
sudo dnf -y install power-profiles-daemon


# disable time wasting startup programs
sudo systemctl disable NetworkManager-wait-online.service
sudo systemctl disable systemd-networkd.service
sudo systemctl disable accounts-daemon.service
sudo systemctl disable debug-shell.service
sudo systemctl disable nfs-client.target
sudo systemctl disable remote-fs.target

sudo dnf -y --noautoremove remove dmraid device-mapper-multipath


# change grup timeout
sudo cp -n /etc/default/grub /etc/default/grub-backup
sudo sed -r -i 's/^GRUB_TIMEOUT_STYLE=(.*)$/GRUB_TIMEOUT_STYLE=menu/m' /etc/default/grub
sudo sed -r -i 's/^GRUB_TIMEOUT=(.*)$/GRUB_TIMEOUT=0/m' /etc/default/grub
sudo update-grub
