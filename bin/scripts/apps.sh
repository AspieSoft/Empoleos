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
  addDnfPkg nemo-fileroller
  sudo sed -r -i 's#^inode/directory=(.*)$#inode/directory=nemo.desktop#m' "/usr/share/applications/gnome-mimeapps.list"
  echo 'OnlyShowIn=X-Cinnamon;Budgie;' | sudo tee -a "/usr/share/applications/nautilus-autorun-software.desktop"
  sudo sed -r -i 's/^\[Desktop Action new-window\]/OnlyShowIn=X-Cinnamon;Budgie;\n\n[Desktop Action new-window]/m' "/usr/share/applications/org.gnome.Nautilus.desktop"

  # prevent updates from changing these files
  sudo chattr +i "/usr/share/applications/nemo.desktop"
  sudo chattr +i "/usr/share/applications/org.gnome.Nautilus.desktop"
fi

# install wine
if [ "$DISTRO_BASE" = "fedora" ]; then
  sudo dnf config-manager --add-repo https://dl.winehq.org/wine-builds/fedora/38/winehq.repo
  sudo dnf -y install winehq-stable
  sudo dnf -y install alsa-plugins-pulseaudio.i686 glibc-devel.i686 glibc-devel libgcc.i686 libX11-devel.i686 freetype-devel.i686 libXcursor-devel.i686 libXi-devel.i686 libXext-devel.i686 libXxf86vm-devel.i686 libXrandr-devel.i686 libXinerama-devel.i686 mesa-libGLU-devel.i686 mesa-libOSMesa-devel.i686 libXrender-devel.i686 libpcap-devel.i686 ncurses-devel.i686 libzip-devel.i686 lcms2-devel.i686 zlib-devel.i686 libv4l-devel.i686 libgphoto2-devel.i686  cups-devel.i686 libxml2-devel.i686 openldap-devel.i686 libxslt-devel.i686 gnutls-devel.i686 libpng-devel.i686 flac-libs.i686 json-c.i686 libICE.i686 libSM.i686 libXtst.i686 libasyncns.i686 libedit.i686 liberation-narrow-fonts.noarch libieee1284.i686 libogg.i686 libsndfile.i686 libuuid.i686 libva.i686 libvorbis.i686 libwayland-client.i686 libwayland-server.i686 llvm-libs.i686 mesa-dri-drivers.i686 mesa-filesystem.i686 mesa-libEGL.i686 mesa-libgbm.i686 nss-mdns.i686 ocl-icd.i686 pulseaudio-libs.i686  sane-backends-libs.i686 tcp_wrappers-libs.i686 unixODBC.i686 samba-common-tools.x86_64 samba-libs.x86_64 samba-winbind.x86_64 samba-winbind-clients.x86_64 samba-winbind-modules.x86_64 mesa-libGL-devel.i686 fontconfig-devel.i686 libXcomposite-devel.i686 libtiff-devel.i686 openal-soft-devel.i686 mesa-libOpenCL-devel.i686 opencl-utils-devel.i686 alsa-lib-devel.i686 gsm-devel.i686 libjpeg-turbo-devel.i686 pulseaudio-libs-devel.i686 pulseaudio-libs-devel gtk3-devel.i686 libattr-devel.i686 libva-devel.i686 libexif-devel.i686 libexif.i686 glib2-devel.i686 mpg123-devel.i686 mpg123-devel.x86_64 libcom_err-devel.i686 libcom_err-devel.x86_64 libFAudio-devel.i686 libFAudio-devel.x86_64
  sudo dnf -y groupinstall "C Development Tools and Libraries"
  sudo dnf -y groupinstall "Development Tools"
elif [ "$DISTRO_BASE" = "ubuntu" -o "$DISTRO_BASE" = "debian" ]; then
  sudo apt -y --install-recommends install wine-stable
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
  if [ "$DISTRO_BASE" = "fedora" ]; then
    sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
    if ! test -f "/etc/yum.repos.d/vscode.repo" ; then
      echo '[code]' | sudo tee -a "/etc/yum.repos.d/vscode.repo"
      echo 'name=Visual Studio Code' | sudo tee -a "/etc/yum.repos.d/vscode.repo"
      echo 'baseurl=https://packages.microsoft.com/yumrepos/vscode' | sudo tee -a "/etc/yum.repos.d/vscode.repo"
      echo 'enabled=1' | sudo tee -a "/etc/yum.repos.d/vscode.repo"
      echo 'gpgcheck=1' | sudo tee -a "/etc/yum.repos.d/vscode.repo"
      echo 'gpgkey=https://packages.microsoft.com/keys/microsoft.asc' | sudo tee -a "/etc/yum.repos.d/vscode.repo"
    fi

    sudo dnf -y check-update

    sudo dnf -y install code
  elif [ "$DISTRO_BASE" = "ubuntu" -o "$DISTRO_BASE" = "debian" ]; then
    sudo snap install --classic code
  fi
fi

# atom
if [ "$(getPkgConfig dnf atom)" != "0" ]; then
  if [ "$DISTRO_BASE" = "fedora" ]; then
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

    sudo dnf -y check-update

    sudo dnf -y install atom
  elif [ "$DISTRO_BASE" = "ubuntu" -o "$DISTRO_BASE" = "debian" ]; then
    sudo snap install --classic atom
  fi
fi

# eclipse
addPkg flatpak flathub org.eclipse.Java

# install browsers
addPkg dnf chromium
addPkg flatpak flathub org.gnome.Epiphany

# install steam
if [ "$(getPkgConfig dnf steam)" != "0" ]; then
  if [ "$DISTRO_BASE" = "fedora" ]; then
    sudo dnf -y module disable nodejs
    sudo dnf -y install steam
    sudo dnf -y module install -y --allowerasing nodejs:16/development
  elif [ "$DISTRO_BASE" = "ubuntu" -o "$DISTRO_BASE" = "debian" ]; then
    sudo apt -y install steam
  fi

  if ! grep -q "Steam" "$HOME/.hidden" ; then
    echo "Steam" | sudo tee -a "$HOME/.hidden"
  fi
  if ! grep -q "Steam" "/etc/skel/.hidden" ; then
    echo "Steam" | sudo tee -a "/etc/skel/.hidden"
  fi
fi
