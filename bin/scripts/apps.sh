#!/bin/bash

source ./bin/common.sh

# install common essentials
addPkg dnf neofetch
addPkg flatpak flathub com.github.tchx84.Flatseal
addPkg dnf dconf-editor gnome-tweaks gnome-extensions-app
if [ "$(hasPkg gnome-tweaks)" = "1" ]; then
  killall gnome-tweaks # this can fix the app if it will not open
fi
addPkg flatpak flathub org.gnome.Extensions
addPkg flatpak flathub com.mattjakeman.ExtensionManager
addPkg dnf gparted

# install nemo file manager (and hide nautilus)
if [ "$(addPkg dnf nemo)" = "1" ]; then
  xdg-mime default nemo.desktop inode/directory application/x-gnome-saved-search
  sudo sed -r -i "s/^OnlyShowIn=/#OnlyShowIn=/m" "/usr/share/applications/nemo.desktop"
  sudo dnf -y install nemo-fileroller
  sudo sed -r -i 's#^inode/directory=(.*)$#inode/directory=nemo.desktop#m' "/usr/share/applications/gnome-mimeapps.list"
  echo 'OnlyShowIn=X-Cinnamon;Budgie;' | sudo tee -a "/usr/share/applications/nautilus-autorun-software.desktop"
  sudo sed -r -i 's/^\[Desktop Action new-window\]/OnlyShowIn=X-Cinnamon;Budgie;\n\n[Desktop Action new-window]/m' "/usr/share/applications/org.gnome.Nautilus.desktop"
fi

# install common tools
addPkg dnf vlc
addPkg flatpak flathub org.blender.Blender
addPkg flatpak flathub org.gimp.GIMP
addPkg dnf pinta
addPkg flatpak flathub com.github.unrud.VideoDownloader
addPkg flatpak flathub org.audacityteam.Audacity
addPkg dnf nm-connection-editor

# install video processing software
addPkg flatpak flathub com.obsproject.Studio
addPkg flatpak flathub org.shotcut.Shotcut

# install code editors

# vscode
if [ "$(getPkgConfig dnf code)" != "0" ]; then
  if ! test -f "/etc/yum.repos.d/vscode.repo" ; then
    echo '[code]' | sudo tee -a "/etc/yum.repos.d/vscode.repo"
    echo 'name=Visual Studio Code' | sudo tee -a "/etc/yum.repos.d/vscode.repo"
    echo 'baseurl=https://packages.microsoft.com/yumrepos/vscode' | sudo tee -a "/etc/yum.repos.d/vscode.repo"
    echo 'enabled=1' | sudo tee -a "/etc/yum.repos.d/vscode.repo"
    echo 'gpgcheck=1' | sudo tee -a "/etc/yum.repos.d/vscode.repo"
    echo 'gpgkey=https://packages.microsoft.com/keys/microsoft.asc' | sudo tee -a "/etc/yum.repos.d/vscode.repo"
  fi

  sudo dnf -y install code
fi

# atom
if [ "$(getPkgConfig dnf atom)" != "0" ]; then
  sudo rpm --import https://packagecloud.io/AtomEditor/atom/gpgkey
  if ! test -f "/etc/yum.repos.d/atom.repo" ; then
    echo '[Atom]' | sudo tee -a "/etc/yum.repos.d/atom.repo"
    echo 'name=atom' | sudo tee -a "/etc/yum.repos.d/atom.repo"
    echo 'baseurl=https://packagecloud.io/AtomEditor/atom/el/7/$basearch' | sudo tee -a "/etc/yum.repos.d/atom.repo"
    echo 'enabled=1' | sudo tee -a "/etc/yum.repos.d/atom.repo"
    echo 'gpgcheck=0' | sudo tee -a "/etc/yum.repos.d/atom.repo"
    echo 'repo_gpgcheck=1' | sudo tee -a "/etc/yum.repos.d/atom.repo"
    echo 'gpgkey=https://packagecloud.io/AtomEditor/atom/gpgkey' | sudo tee -a "/etc/yum.repos.d/atom.repo"
  fi

  sudo dnf -y install atom
fi

# eclipse
addPkg flatpak flathub org.eclipse.Java

# install browsers
addPkg dnf chromium
addPkg flatpak flathub org.gnome.Epiphany

# install steam
if [ "$(getPkgConfig dnf steam)" != "0" ]; then
  sudo dnf -y module disable nodejs
  sudo dnf -y install steam
  sudo dnf -y module install -y --allowerasing nodejs:16/development
  if ! grep -q "Steam" "$HOME/.hidden" ; then
    echo "Steam" | sudo tee -a "$HOME/.hidden"
  fi
  if ! grep -q "Steam" "/etc/skel/.hidden" ; then
    echo "Steam" | sudo tee -a "/etc/skel/.hidden"
  fi
fi
