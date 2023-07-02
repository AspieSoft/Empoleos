#!/bin/bash

source ./bin/common.sh

# install shortcuts
if ! [ -f "$HOME/.bashrc" ]; then
  sudo touch "$HOME/.bashrc"
fi

if ! grep -q "# empoleos-aliases" "$HOME/.bashrc" ; then
  echo '# empoleos-aliases' | sudo tee -a "$HOME/.bashrc"
  echo 'if [ -f ~/.empoleos-aliases ]; then' | sudo tee -a "$HOME/.bashrc"
  echo '. ~/.empoleos-aliases' | sudo tee -a "$HOME/.bashrc"
  echo 'fi' | sudo tee -a "$HOME/.bashrc"
fi

if ! [ -f "$HOME/.empoleos-aliases" ]; then
  sudo cp "./bin/apps/empoleos-aliases.sh" "$HOME/.empoleos-aliases"
fi

# install shortcuts for new users
if ! [ -f "/etc/skel/.bashrc" ]; then
  sudo touch "/etc/skel/.bashrc"
fi

if ! grep -q "# empoleos-aliases" "/etc/skel/.bashrc" ; then
  echo '# empoleos-aliases' | sudo tee -a "/etc/skel/.bashrc"
  echo 'if [ -f ~/.empoleos-aliases ]; then' | sudo tee -a "/etc/skel/.bashrc"
  echo '. ~/.empoleos-aliases' | sudo tee -a "/etc/skel/.bashrc"
  echo 'fi' | sudo tee -a "/etc/skel/.bashrc"
fi

if ! [ -f "/etc/skel/.empoleos-aliases" ]; then
  sudo cp "./bin/apps/empoleos-aliases.sh" "/etc/skel/.empoleos-aliases"
fi
