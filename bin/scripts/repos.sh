#!/bin/bash

# install dnf if not installed
if [ "$(sudo which dnf 2>/dev/null)" = "" ]; then
  sudo rpm-ostree update -y
  sudo rpm-ostree install -y dnf
fi

# update
sudo dnf -y update

if ! grep -R "^# Added for Speed" "/etc/dnf/dnf.conf"; then
  echo "# Added for Speed" | sudo tee -a /etc/dnf/dnf.conf
  #echo "fastestmirror=True" | sudo tee -a /etc/dnf/dnf.conf
  echo "max_parallel_downloads=5" | sudo tee -a /etc/dnf/dnf.conf
  echo "defaultyes=True" | sudo tee -a /etc/dnf/dnf.conf
  echo "keepcache=True" | sudo tee -a /etc/dnf/dnf.conf
fi

# add rpmfusion repos
sudo dnf -y install https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
sudo dnf -y install https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
sudo fedora-third-party enable
sudo fedora-third-party refresh
sudo dnf -y groupupdate core

# add flatpak
sudo dnf -y install flatpak
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# install snap
sudo dnf -y install snapd
sudo ln -s /var/lib/snapd/snap /snap
sudo snap install snap-store

# install media codecs
sudo dnf install -y --skip-broken @multimedia
sudo dnf -y groupupdate multimedia --setop="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin --skip-broken
sudo dnf -y groupupdate sound-and-video
sudo dnf -y --skip-broken install ffmpeg

# install repositories
sudo dnf -y install fedora-workstation-repositories
sudo dnf -y config-manager --set-enabled google-chrome

# update
sudo dnf -y check-update
sudo flatpak update -y

sudo dnf -y makecache
sudo dnf -y update
