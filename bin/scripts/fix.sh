#!/bin/bash

# install file systems
sudo dnf -y install btrfs-progs lvm2 xfsprogs udftools

# install printer software
sudo dnf -y install hplip hplip-gui

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
