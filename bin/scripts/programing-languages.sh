#!/bin/bash

# install python, c++, and java
addDnfPkg python python3 python-pip python3-pip
addDnfPkg gcc-c++ make gcc #edit for apt
addDnfPkg java-1.8.0-openjdk.x86_64
addDnfPkg java-11-openjdk.x86_64
addDnfPkg java-latest-openjdk.x86_64

# install nodejs
addDnfPkg nodejs
if [ "$DISTRO_BASE" = "ubuntu" -o "$DISTRO_BASE" = "debian" ]; then
  sudo apt -y install npm
fi
sudo npm -g i npm
npm config set prefix ~/.npm

# add npm to current user
if ! [ -f "$HOME/.zshrc" ]; then
  sudo touch "$HOME/.zshrc"
fi
if ! [ -f "$HOME/.profile" ]; then
  sudo touch "$HOME/.profile"
fi
if ! grep -q 'export N_PREFIX="~/.npm"' "$HOME/.zshrc" ; then
  echo 'export N_PREFIX="~/.npm"' | sudo tee -a "$HOME/.zshrc"
fi
if ! grep -q 'export N_PREFIX="~/.npm"' "$HOME/.profile" ; then
  echo 'export N_PREFIX="~/.npm"' | sudo tee -a "$HOME/.profile"
fi
if ! [ -d "$HOME/.npm" ]; then
  sudo mkdir $(whoami) "$HOME/.npm"
  sudo chown -R $(whoami) "$HOME/.npm"
fi

# add npm for new user
if ! [ -f "/etc/skel/.zshrc" ]; then
  sudo touch "/etc/skel/.zshrc"
fi
if ! [ -f "/etc/skel/.profile" ]; then
  sudo touch "/etc/skel/.profile"
fi
if ! grep -q 'export N_PREFIX="~/.npm"' "/etc/skel/.zshrc" ; then
  echo 'export N_PREFIX="~/.npm"' | sudo tee -a "/etc/skel/.zshrc"
fi
if ! grep -q 'export N_PREFIX="~/.npm"' "/etc/skel/.profile" ; then
  echo 'export N_PREFIX="~/.npm"' | sudo tee -a "/etc/skel/.profile"
fi

# install yarn and git
sudo npm -g i yarn
addDnfPkg git

# install golang
addDnfPkg golang
sudo ln -s /lib/golang /usr/share/go
addDnfPkg pcre-devel
if ! grep -q "go" "$HOME/.hidden" ; then
  echo "go" | sudo tee -a "$HOME/.hidden"
fi
if ! grep -q "go" "/etc/skel/.hidden" ; then
  echo "go" | sudo tee -a "/etc/skel/.hidden"
fi

# install docker
if [ "$DISTRO_BASE" = "fedora" ]; then
  sudo dnf -y install dnf-plugins-core
  sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
  sudo dnf -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
elif [ "$DISTRO_BASE" = "debian" ]; then
  #todo: auto install docker on debian
  echo "docker not yet auto installed for debian"
elif [ "$DISTRO_BASE" = "ubuntu" ]; then
  #todo: auto install docker on ubuntu
  echo "docker not yet auto installed for ubuntu"
fi
sudo systemctl enable docker
sudo systemctl start docker
