#!/bin/bash

source ./bin/common.sh

# update
sudo apt -y update
sudo apt -y upgrade

# install nala
echo "deb http://deb.volian.org/volian/ scar main" | sudo tee /etc/apt/sources.list.d/volian-archive-scar-unstable.list; wget -qO - https://deb.volian.org/volian/scar.key | sudo tee /etc/apt/trusted.gpg.d/volian-archive-scar-unstable.gpg
sudo apt -y update
sudo apt -y install nala

# add flatpak
sudo apt -y install flatpak gnome-software-plugin-flatpak gnome-software
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# install snap
sudo apt -y install snapd
sudo ln -s /var/lib/snapd/snap /snap
sudo snap install snap-store
sudo snap install core
sudo snap refresh core

# install media codecs
sudo apt -y install ffmpeg

# update
sudo apt -y update
sudo flatpak update -y

sudo apt -y update
sudo apt -y upgrade
