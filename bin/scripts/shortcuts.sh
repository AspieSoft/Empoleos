#!/bin/bash

#todo: change github repo and folder for for shrotcuts

# install shortcuts
if ! [ -f "$HOME/.bashrc" ]; then
  sudo touch "$HOME/.bashrc"
fi

if ! grep -q "# aspiesoft-fedora-setup-aliases" "$HOME/.bashrc" ; then
  echo '# aspiesoft-fedora-setup-aliases' | sudo tee -a "$HOME/.bashrc"
  echo 'if [ -f ~/.aspiesoft-fedora-setup-aliases ]; then' | sudo tee -a "$HOME/.bashrc"
  echo '. ~/.aspiesoft-fedora-setup-aliases' | sudo tee -a "$HOME/.bashrc"
  echo 'fi' | sudo tee -a "$HOME/.bashrc"
fi

if ! [ -f "$HOME/.aspiesoft-fedora-setup-aliases" ]; then
  sudo touch "$HOME/.aspiesoft-fedora-setup-aliases"
fi

echo "$(cat assets/apps/aspiesoft-fedora-setup-aliases.sh)" | sudo tee "$HOME/.aspiesoft-fedora-setup-aliases"

# install shortcuts for new users
if ! [ -f "/etc/skel/.bashrc" ]; then
  sudo touch "/etc/skel/.bashrc"
fi

if ! grep -q "# aspiesoft-fedora-setup-aliases" "/etc/skel/.bashrc" ; then
  echo '# aspiesoft-fedora-setup-aliases' | sudo tee -a "/etc/skel/.bashrc"
  echo 'if [ -f ~/.aspiesoft-fedora-setup-aliases ]; then' | sudo tee -a "/etc/skel/.bashrc"
  echo '. ~/.aspiesoft-fedora-setup-aliases' | sudo tee -a "/etc/skel/.bashrc"
  echo 'fi' | sudo tee -a "/etc/skel/.bashrc"
fi

if ! [ -f "/etc/skel/.aspiesoft-fedora-setup-aliases" ]; then
  sudo touch "/etc/skel/.aspiesoft-fedora-setup-aliases"
fi

echo "$(cat assets/apps/aspiesoft-fedora-setup-aliases.sh)" | sudo tee "/etc/skel/.aspiesoft-fedora-setup-aliases"
