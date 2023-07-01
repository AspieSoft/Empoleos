#!/bin/bash

# get distro base
if [ "$(cat /proc/version | grep 'Red Hat')" ] && [ "$(sudo which dnf 2>/dev/null)" != "" -o "$(sudo which yum 2>/dev/null)" != "" -o "$(sudo which rpm-ostree 2>/dev/null)" != "" -o "$(sudo which rpm 2>/dev/null)" != "" ]; then
  export DISTRO_BASE="fedora"
elif [ "$(cat /proc/version | grep 'Debian')" ] && [ "$(sudo which apt 2>/dev/null)" != "" -o "$(sudo which apt-get 2>/dev/null)" != "" -o "$(sudo which nala 2>/dev/null)" != "" -o "$(sudo which dpkg 2>/dev/null)" != "" ]; then
  export DISTRO_BASE="debian"
elif [ "$(cat /proc/version | grep 'Ubuntu')" ] && [ "$(sudo which apt 2>/dev/null)" != "" -o "$(sudo which apt-get 2>/dev/null)" != "" -o "$(sudo which nala 2>/dev/null)" != "" -o "$(sudo which dpkg 2>/dev/null)" != "" ]; then
  export DISTRO_BASE="ubuntu"
fi


# handle backup config edits
function dnf {
  if [ "$DISTRO_BASE" = "fedora" ]; then
    local action=""
    for key in $@; do
      if [[ "$key" =~ "-".* ]]; then
        continue
      elif [ "$action" = "add" ]; then
        /etc/empoleos/edit-config/edit-config "/etc/empoleos/config.yml" "dnf" "$key" "yes"
        continue
      elif [ "$action" = "rm" ]; then
        /etc/empoleos/edit-config/edit-config "/etc/empoleos/config.yml" "dnf" "$key" "no"
        continue
      elif [ "$key" = "install" -o "$key" = "reinstall" ]; then
        action="add"
        continue
      elif [ "$key" = "remove" -o "$key" = "autoremove" ]; then
        action="rm"
        continue
      else
        break
      fi
    done
  fi

  command dnf "$@"
}

function apt {
  if [ "$DISTRO_BASE" = "ubuntu" -o "$DISTRO_BASE" = "debian" ]; then
    local action=""
    for key in $@; do
      if [[ "$key" =~ "-".* ]]; then
        continue
      elif [ "$action" = "add" ]; then
        /etc/empoleos/edit-config/edit-config "/etc/empoleos/config.yml" "apt" "$key" "yes"
        continue
      elif [ "$action" = "rm" ]; then
        /etc/empoleos/edit-config/edit-config "/etc/empoleos/config.yml" "apt" "$key" "no"
        continue
      elif [ "$key" = "install" -o "$key" = "reinstall" ]; then
        action="add"
        continue
      elif [ "$key" = "remove" -o "$key" = "autoremove" ]; then
        action="rm"
        continue
      else
        break
      fi
    done
  fi

  command nala "$@"
}

function apt-get {
  if [ "$DISTRO_BASE" = "ubuntu" -o "$DISTRO_BASE" = "debian" ]; then
    local action=""
    for key in $@; do
      if [[ "$key" =~ "-".* ]]; then
        continue
      elif [ "$action" = "add" ]; then
        /etc/empoleos/edit-config/edit-config "/etc/empoleos/config.yml" "apt" "$key" "yes"
        continue
      elif [ "$action" = "rm" ]; then
        /etc/empoleos/edit-config/edit-config "/etc/empoleos/config.yml" "apt" "$key" "no"
        continue
      elif [ "$key" = "install" -o "$key" = "reinstall" ]; then
        action="add"
        continue
      elif [ "$key" = "remove" -o "$key" = "autoremove" ]; then
        action="rm"
        continue
      else
        break
      fi
    done
  fi

  command apt-get "$@"
}

function nala {
  if [ "$DISTRO_BASE" = "ubuntu" -o "$DISTRO_BASE" = "debian" ]; then
    local action=""
    for key in $@; do
      if [[ "$key" =~ "-".* ]]; then
        continue
      elif [ "$action" = "add" ]; then
        /etc/empoleos/edit-config/edit-config "/etc/empoleos/config.yml" "apt" "$key" "yes"
        continue
      elif [ "$action" = "rm" ]; then
        /etc/empoleos/edit-config/edit-config "/etc/empoleos/config.yml" "apt" "$key" "no"
        continue
      elif [ "$key" = "install" -o "$key" = "reinstall" ]; then
        action="add"
        continue
      elif [ "$key" = "remove" -o "$key" = "autoremove" ]; then
        action="rm"
        continue
      else
        break
      fi
    done
  fi

  command nala "$@"
}

function flatpak {
  local action=""
  local repo=""
  for key in $@; do
    if [[ "$key" =~ "-".* ]]; then
      continue
    elif ! [ "$repo" = "" ]; then
      if [ "$action" = "add-repo" ]; then
        /etc/empoleos/edit-config/edit-config "/etc/empoleos/config.yml" "flatpak-repo" "$key" "yes" "$repo"
      elif [ "$action" = "rm-repo" ]; then
        /etc/empoleos/edit-config/edit-config "/etc/empoleos/config.yml" "flatpak-repo" "$key" "no" "$repo"
      fi
      repo=""
      continue
    elif [ "$action" = "add" ]; then
      /etc/empoleos/edit-config/edit-config "/etc/empoleos/config.yml" "flatpak" "$key" "yes" "$repo"
      continue
    elif [ "$action" = "rm" ]; then
      /etc/empoleos/edit-config/edit-config "/etc/empoleos/config.yml" "flatpak" "$key" "no" "$repo"
      continue
    elif [ "$action" = "add-repo" ]; then
      repo="$key"
      continue
    elif [ "$action" = "rm-repo" ]; then
      repo="$key"
      continue
    elif [ "$key" = "install" ]; then
      action="add"
      continue
    elif [ "$key" = "uninstall" ]; then
      action="rm"
      continue
    elif [ "$key" = "remote-add" ]; then
      action="add-repo"
      continue
    elif [ "$key" = "remote-delete" ]; then
      action="rm-repo"
      continue
    else
      break
    fi
  done

  command flatpak "$@"
}

function snap {
  local action=""
  for key in $@; do
    if [[ "$key" =~ "-".* ]]; then
      continue
    elif [ "$action" = "add" ]; then
      /etc/empoleos/edit-config/edit-config "/etc/empoleos/config.yml" "snap" "$key" "yes"
      continue
    elif [ "$action" = "rm" ]; then
      
      /etc/empoleos/edit-config/edit-config "/etc/empoleos/config.yml" "snap" "$key" "no"
      continue
    elif [ "$key" = "install" ]; then
      action="add"
      continue
    elif [ "$key" = "remove" ]; then
      action="rm"
      continue
    else
      break
    fi
  done

  command snap "$@"
}

function sudo {
  if [ "$1" = "dnf" ] && [ "$DISTRO_BASE" = "fedora" ]; then
    local firstIndex="true"
    local action=""
    for key in $@; do
      if [ "$firstIndex" = "true" ]; then
        firstIndex="false"
        continue
      elif [[ "$key" =~ "-".* ]]; then
        continue
      elif [ "$action" = "add" ]; then
        /etc/empoleos/edit-config/edit-config "/etc/empoleos/config.yml" "dnf" "$key" "yes"
        continue
      elif [ "$action" = "rm" ]; then
        /etc/empoleos/edit-config/edit-config "/etc/empoleos/config.yml" "dnf" "$key" "no"
        continue
      elif [ "$key" = "install" -o "$key" = "reinstall" ]; then
        action="add"
        continue
      elif [ "$key" = "remove" -o "$key" = "autoremove" ]; then
        action="rm"
        continue
      else
        break
      fi
    done
  elif [ "$1" = "apt" -o "$1" = "apt-get" -o "$1" = "nala" ] && [ "$DISTRO_BASE" = "ubuntu" -o "$DISTRO_BASE" = "debian" ]; then
    local firstIndex="true"
    local action=""
    for key in $@; do
      if [ "$firstIndex" = "true" ]; then
        firstIndex="false"
        continue
      elif [[ "$key" =~ "-".* ]]; then
        continue
      elif [ "$action" = "add" ]; then
        /etc/empoleos/edit-config/edit-config "/etc/empoleos/config.yml" "apt" "$key" "yes"
        continue
      elif [ "$action" = "rm" ]; then
        /etc/empoleos/edit-config/edit-config "/etc/empoleos/config.yml" "apt" "$key" "no"
        continue
      elif [ "$key" = "install" -o "$key" = "reinstall" ]; then
        action="add"
        continue
      elif [ "$key" = "remove" -o "$key" = "autoremove" ]; then
        action="rm"
        continue
      else
        break
      fi
    done
  elif [ "$1" = "flatpak" ]; then
    local firstIndex="true"
    local action=""
    local repo=""
    for key in $@; do
      if [ "$firstIndex" = "true" ]; then
        firstIndex="false"
        continue
      elif [[ "$key" =~ "-".* ]]; then
        continue
      elif ! [ "$repo" = "" ]; then
        if [ "$action" = "add-repo" ]; then
          /etc/empoleos/edit-config/edit-config "/etc/empoleos/config.yml" "flatpak-repo" "$key" "yes" "$repo"
        elif [ "$action" = "rm-repo" ]; then
          /etc/empoleos/edit-config/edit-config "/etc/empoleos/config.yml" "flatpak-repo" "$key" "no" "$repo"
        fi
        repo=""
        continue
      elif [ "$action" = "add" ]; then
        /etc/empoleos/edit-config/edit-config "/etc/empoleos/config.yml" "flatpak" "$key" "yes" "$repo"
        continue
      elif [ "$action" = "rm" ]; then
        /etc/empoleos/edit-config/edit-config "/etc/empoleos/config.yml" "flatpak" "$key" "no" "$repo"
        continue
      elif [ "$action" = "add-repo" ]; then
        repo="$key"
        continue
      elif [ "$action" = "rm-repo" ]; then
        repo="$key"
        continue
      elif [ "$key" = "install" ]; then
        action="add"
        continue
      elif [ "$key" = "uninstall" ]; then
        action="rm"
        continue
      elif [ "$key" = "remote-add" ]; then
        action="add-repo"
        continue
      elif [ "$key" = "remote-delete" ]; then
        action="rm-repo"
        continue
      else
        break
      fi
    done
  elif [ "$1" = "snap" ]; then
    local firstIndex="true"
    local action=""
    for key in $@; do
      if [ "$firstIndex" = "true" ]; then
        firstIndex="false"
        continue
      elif [[ "$key" =~ "-".* ]]; then
        continue
      elif [ "$action" = "add" ]; then
        /etc/empoleos/edit-config/edit-config "/etc/empoleos/config.yml" "snap" "$key" "yes"
        continue
      elif [ "$action" = "rm" ]; then
        /etc/empoleos/edit-config/edit-config "/etc/empoleos/config.yml" "snap" "$key" "no"
        continue
      elif [ "$key" = "install" ]; then
        action="add"
        continue
      elif [ "$key" = "remove" ]; then
        action="rm"
        continue
      else
        break
      fi
    done
  fi

  command sudo "$@"
}


# optional useful functions
function update {
  if [ "$DISTRO_BASE" = "fedora" ]; then
    sudo dnf -y update
  elif [ "$DISTRO_BASE" = "ubuntu" -o "$DISTRO_BASE" = "debian" ]; then
    sudo apt -y update
    sudo apt -y upgrade
  fi

  sudo bash /etc/empoleos/update.sh

  if [ "$DISTRO_BASE" = "fedora" ]; then
    sudo dnf clean all
  elif [ "$DISTRO_BASE" = "ubuntu" -o "$DISTRO_BASE" = "debian" ]; then
    sudo apt -y autoremove
  fi
}

function backup {
  update

  sudo bash /etc/empoleos/backup.sh
}

function avscan {
  local scanDir="$1"
  if [ "$scanDir" = "" ]; then
    scanDir="$HOME"
  fi
  sudo nice -n 15 clamscan -r --bell --move="/VirusScan/quarantine" --exclude-dir="/VirusScan/quarantine" --exclude-dir="/home/$USER/.clamtk/viruses" --exclude-dir="smb4k" --exclude-dir="/run/user/$USER/gvfs" --exclude-dir="/home/$USER/.gvfs" --exclude-dir=".thunderbird" --exclude-dir=".mozilla-thunderbird" --exclude-dir=".evolution" --exclude-dir="Mail" --exclude-dir="kmail" --exclude-dir="^/sys" "$scanDir"
}
