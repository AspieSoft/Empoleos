#!/bin/bash

function addPkgToBackup {
  #todo: add package to backup config.yml
  # $1: dnf, flatpak, snap, flatpak-remote
  # $2: package-name
  # flatpak-remote:
  # - $2: flathub
  # - $3: https://flathub.org/repo/flathub.flatpakrepo
}

function rmPkgFromBackup {
  #todo: remove package from backup config.yml
  # $1: dnf, flatpak, snap, flatpak-remote
  # $2: package-name
  # flatpak-remote:
  # - $2: flathub
  # - $3: https://flathub.org/repo/flathub.flatpakrepo
}

function dnf {
  local action=""
  for key in $@; do
    if [[ "$key" =~ "-".* ]]; then
      continue
    elif [ "$action" = "add" ]; then
      addPkgToBackup "dnf" "$key"
      continue
    elif [ "$action" = "rm" ]; then
      rmPkgFromBackup "dnf" "$key"
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

  command dnf "$@"
}

function flatpak {
  local action=""
  local remote=""
  for key in $@; do
    if [[ "$key" =~ "-".* ]]; then
      continue
    elif ! [ "$remote" = "" ]; then
      if [ "$action" = "add-remote" ]; then
        addPkgToBackup "flatpak-remote" "$remote" "$key"
      elif [ "$action" = "rm-remote" ]; then
        rmPkgFromBackup "flatpak-remote" "$remote" "$key"
      fi
      remote=""
      continue
    elif [ "$action" = "add" ]; then
      addPkgToBackup "flatpak" "$key"
      continue
    elif [ "$action" = "rm" ]; then
      rmPkgFromBackup "flatpak" "$key"
      continue
    elif [ "$action" = "add-remote" ]; then
      remote="$key"
      continue
    elif [ "$action" = "rm-remote" ]; then
      remote="$key"
      continue
    elif [ "$key" = "install" ]; then
      action="add"
      continue
    elif [ "$key" = "uninstall" ]; then
      action="rm"
      continue
    elif [ "$key" = "remote-add" ]; then
      action="add-remote"
      continue
    elif [ "$key" = "remote-delete" ]; then
      action="rm-remote"
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
      addPkgToBackup "snap" "$key"
      continue
    elif [ "$action" = "rm" ]; then
      rmPkgFromBackup "snap" "$key"
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
  if [ "$1" = "dnf" ]; then
    local firstIndex="true"
    local action=""
    for key in $@; do
      if [ "$firstIndex" = "true" ]; then
        firstIndex="false"
        continue
      elif [[ "$key" =~ "-".* ]]; then
        continue
      elif [ "$action" = "add" ]; then
        addPkgToBackup "dnf" "$key"
        continue
      elif [ "$action" = "rm" ]; then
        rmPkgFromBackup "dnf" "$key"
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
    local remote=""
    for key in $@; do
      if [ "$firstIndex" = "true" ]; then
        firstIndex="false"
        continue
      elif [[ "$key" =~ "-".* ]]; then
        continue
      elif ! [ "$remote" = "" ]; then
        if [ "$action" = "add-remote" ]; then
          addPkgToBackup "flatpak-remote" "$remote" "$key"
        elif [ "$action" = "rm-remote" ]; then
          rmPkgFromBackup "flatpak-remote" "$remote" "$key"
        fi
        remote=""
        continue
      elif [ "$action" = "add" ]; then
        addPkgToBackup "flatpak" "$key"
        continue
      elif [ "$action" = "rm" ]; then
        rmPkgFromBackup "flatpak" "$key"
        continue
      elif [ "$action" = "add-remote" ]; then
        remote="$key"
        continue
      elif [ "$action" = "rm-remote" ]; then
        remote="$key"
        continue
      elif [ "$key" = "install" ]; then
        action="add"
        continue
      elif [ "$key" = "uninstall" ]; then
        action="rm"
        continue
      elif [ "$key" = "remote-add" ]; then
        action="add-remote"
        continue
      elif [ "$key" = "remote-delete" ]; then
        action="rm-remote"
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
        addPkgToBackup "snap" "$key"
        continue
      elif [ "$action" = "rm" ]; then
        rmPkgFromBackup "snap" "$key"
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


function update {
  sudo dnf -y update
  sudo bash /etc/empoleos/update.sh
  sudo dnf clean all
}

function backup {
  sudo dnf -y update
  sudo bash /etc/empoleos/update.sh
  sudo dnf clean all

  sudo bash /etc/empoleos/backup.sh
}

function avscan {
  local scanDir="$1"
  if [ "$scanDir" = "" ]; then
    scanDir="$HOME"
  fi
  sudo nice -n 15 clamscan -r --bell --move="/VirusScan/quarantine" --exclude-dir="/VirusScan/quarantine" --exclude-dir="/home/$USER/.clamtk/viruses" --exclude-dir="smb4k" --exclude-dir="/run/user/$USER/gvfs" --exclude-dir="/home/$USER/.gvfs" --exclude-dir=".thunderbird" --exclude-dir=".mozilla-thunderbird" --exclude-dir=".evolution" --exclude-dir="Mail" --exclude-dir="kmail" --exclude-dir="^/sys" "$scanDir"
}
