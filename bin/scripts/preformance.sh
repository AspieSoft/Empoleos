#!/bin/bash

source ./bin/common.sh

# install preload
if [ "$DISTRO_BASE" = "fedora" ]; then
  sudo dnf -y copr enable elxreno/preload
  sudo dnf -y install preload
elif [ "$DISTRO_BASE" = "ubuntu" -o "$DISTRO_BASE" = "debian" ]; then
  sudo apt -y install preload
fi
sudo systemctl start preload
sudo systemctl enable preload

# install tlp
addDnfPkg tlp tlp-rdw
sudo systemctl start tlp
sudo systemctl enable tlp
sudo tlp start

# install thermald
addDnfPkg thermald
sudo systemctl start thermald
sudo systemctl enable thermald


# install auto-cpufreq (not recommended with tlp)
#sudo snap install auto-cpufreq
#sudo auto-cpufreq --install


addDnfPkg gnome-power-manager power-profiles-daemon


# disable time wasting startup programs
if [ "$DISTRO_BASE" = "fedora" ]; then
  sudo systemctl disable NetworkManager-wait-online.service
  sudo systemctl disable systemd-networkd.service
  sudo systemctl disable accounts-daemon.service
  sudo systemctl disable debug-shell.service
  sudo systemctl disable nfs-client.target
  sudo systemctl disable remote-fs.target

  sudo dnf -y --noautoremove remove dmraid device-mapper-multipath
elif [ "$DISTRO_BASE" = "ubuntu" -o "$DISTRO_BASE" = "debian" ]; then
  sudo systemctl disable postfix.service # for email server
  sudo systemctl disable NetworkManager-wait-online.service # wastes time connectiong to wifi
  sudo systemctl disable networkd-dispatcher.service # depends on the time waster above
  sudo systemctl disable systemd-networkd.service # depends on the time waster above
  sudo systemctl disable accounts-daemon.service # is a potential securite risk
  sudo systemctl disable debug-shell.service # opens a giant security hole
  sudo systemctl disable pppd-dns.service # dial-up internet (its way outdated)

  # sudo systemctl disable whoopsie.service # ubuntu error reporting
fi


# change grup timeout
sudo cp -n /etc/default/grub /etc/default/grub-backup
sudo sed -r -i 's/^GRUB_TIMEOUT_STYLE=(.*)$/GRUB_TIMEOUT_STYLE=menu/m' /etc/default/grub
sudo sed -r -i 's/^GRUB_TIMEOUT=(.*)$/GRUB_TIMEOUT=0/m' /etc/default/grub
sudo update-grub
