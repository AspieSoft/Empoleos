#!/bin/bash

source ./bin/common.sh

# install file systems
addDnfPkg btrfs-progs lvm2 xfsprogs udftools

# install 7zip
addDnfPkg p7zip p7zip-plugins

# install printer software
addDnfPkg hplip hplip-gui

# install inotify-tools
addDnfPkg inotify-tools

# hide core files
if ! [ -f "$HOME/.hidden" ]; then
  sudo touch "$HOME/.hidden"
fi

if ! grep -q "core" "$HOME/.hidden" ; then
  echo "core" | sudo tee -a "$HOME/.hidden"
fi
if ! grep -q "snap" "$HOME/.hidden" ; then
  echo "snap" | sudo tee -a "$HOME/.hidden"
fi

# hide core files for new users
if ! [ -f "/etc/skel/.hidden" ]; then
  sudo touch "/etc/skel/.hidden"
fi

if ! grep -q "core" "/etc/skel/.hidden" ; then
  echo "core" | sudo tee -a "/etc/skel/.hidden"
fi
if ! grep -q "snap" "/etc/skel/.hidden" ; then
  echo "snap" | sudo tee -a "/etc/skel/.hidden"
fi
