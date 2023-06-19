#!/bin/bash

cd $(dirname "$0")
dir="$PWD"

autoUpdates="y"

for opt in "$@"; do
  if [ "$opt" = "-y" ]; then
    autoYes="1"
  elif [[ "$opt" =~ "--config=".* ]]; then
    configFile="${opt/--config=/}"
  else
    echo "error: option not recognized: '$opt'"
    exit
  fi
done

if ! [ "autoYes" = "1" ]; then
  echo
  echo "Notice: This script will completely transform your desktop and modify your settings!"
  echo "Creating a backup before running this script is recommended."
  echo "Your gnome session will restart (and log you out) when the install is complete."
  echo
  read -n1 -p "Would you like to continue with the install (Y/n)? " input ; echo >&2

  if ! [ "$input" = "y" -o "$input" = "Y" -o "$input" = "" -o "$input" = " " ] ; then
    echo "install canceled!"
    exit
  fi

  if [ "$configFile" = "" ]; then
    echo "Choose a config file you would like to use"
    echo "or leave blank for default setup"
    read -p "Config File (yml): " configFile
  fi

  #todo: add auto update option to config file
  read -n1 -p "Would you like automatic updates to be pulled from the github repo (Y/n)? " autoUpdates
elif [ "$configFile" = "" ]; then
  if test -f empoleos.yml; then
    configFile="empoleos.yml"
  fi
fi

echo "Starting Install..."
echo


# verify checksums
gitSum=$(curl --silent "https://raw.githubusercontent.com/AspieSoft/empoleos/master/install.sh" | sha256sum | sed -E 's/([a-zA-Z0-9]+).*$/\1/')
sum=$(sha256sum "install.sh" | sed -E 's/([a-zA-Z0-9]+).*$/\1/')
if ! [ "$sum" = "$gitSum" ]; then
  echo "error: checksum failed!"
  exit
fi

gitSum=$(curl --silent "https://raw.githubusercontent.com/AspieSoft/empoleos/master/bin/common.sh" | sha256sum | sed -E 's/([a-zA-Z0-9]+).*$/\1/')
sum=$(sha256sum "bin/common.sh" | sed -E 's/([a-zA-Z0-9]+).*$/\1/')
if ! [ "$sum" = "$gitSum" ]; then
  echo "error: checksum failed!"
  exit
fi


function cleanup {
  # reset login timeout
  sudo sed -r -i 's/^Defaults([\t ]+)(.*)env_reset(.*), (timestamp_timeout=1801,?\s*)+$/Defaults\1\2env_reset\3/m' /etc/sudoers &>/dev/null

  # enable sleep
  sudo systemctl --runtime unmask sleep.target suspend.target hibernate.target hybrid-sleep.target &>/dev/null
  gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type 'suspend' &>/dev/null

  # enable auto updates
  gsettings set org.gnome.software download-updates true

  # enable auto suspend
  sudo perl -0777 -i -pe 's/#AspieSoft-TEMP-START(.*)#AspieSoft-TEMP-END//s' /etc/systemd/logind.conf &>/dev/null

  cd "$dir"
}
trap cleanup EXIT

function cleanupexit {
  cleanup
  exit
}
trap cleanupexit SIGINT


# To log into sudo with password prompt
sudo echo


# extend login timeout
sudo sed -r -i 's/^Defaults([\t ]+)(.*)env_reset(.*)$/Defaults\1\2env_reset\3, timestamp_timeout=1801/m' /etc/sudoers &>/dev/null

# disable sleep
sudo systemctl --runtime mask sleep.target suspend.target hibernate.target hybrid-sleep.target &>/dev/null
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type 'nothing' &>/dev/null

# disable auto updates
gsettings set org.gnome.software download-updates false

# disable auto suspend
echo "#AspieSoft-TEMP-START" | sudo tee -a /etc/systemd/logind.conf &>/dev/null
echo "HandleLidSwitch=ignore" | sudo tee -a /etc/systemd/logind.conf &>/dev/null
echo "HandleLidSwitchDocked=ignore" | sudo tee -a /etc/systemd/logind.conf &>/dev/null
echo "IdleAction=ignore" | sudo tee -a /etc/systemd/logind.conf &>/dev/null
echo "#AspieSoft-TEMP-END" | sudo tee -a /etc/systemd/logind.conf &>/dev/null


# set theme basics
gsettings set org.gnome.desktop.interface clock-format 12h
gsettings set org.gnome.desktop.interface color-scheme "prefer-dark"


# add bash dependencies
source ./bin/common.sh

# verify script checksums
for file in bin/scripts/*.sh; do
  gitVerify "$file"
done


# load config file
if test -f "$configFile"; then
  hasConf="1"
  eval $(parse_yaml "$configFile" "empoleosCONF_")
else
  hasConf="0"
fi


# run scripts
bash ./bin/repos.sh
bash ./bin/fix.sh
bash ./bin/preformance.sh

bash ./bin/programing-languages.sh
bash ./bin/security.sh

bash ./bin/apps.sh

bash ./bin/shortcuts.sh

bash ./bin/theme.sh


#todo: fix config packages to only read from dnf, flatpak, and snap lists (may include other non-package config options)
# handle config packages
if [ "$hasConf" = "1" ]; then
  pkgManUsed=""
  for pkgMan in $empoleosCONF_; do
    if [ "$pkgMan" = "flatpak" ]; then
      continue # flatpak will also print flatpak_flathub and other lists
    fi

    hasUsedPkgMan=0
    for used in $pkgManUsed; do
      if [ "$pkgMan" = "$used" ]; then
        hasUsedPkgMan=1
        break
      fi
    done

    if [ "$hasUsedPkgMan" = "1" ]; then
      continue
    fi

    pkgManUsed="$pkgManUsed $pkgMan"

    pkgType=""
    if [[ "$pkgMan" =~ "flatpak_".* ]]; then
      pkgType="$(echo $pkgMan | sed -e 's/^[A-Za-z0-9]*_//g')"
      pkgMan="flatpak"
      key="empoleosCONF_${pkgMan}_${pkgType}_"
    else
      key="empoleosCONF_${pkgMan}_"
    fi

    for pkg in ${!key}; do
      pkg="$(echo $pkg | sed -e 's/__l__/-/g' -e 's/__d__/./g')"
      val=$(getPkgConfig "$pkgMan" "$pkg" "$pkgType")

      if [ "$val" = "1" ]; then
        if [ "$pkgType" != "" ]; then
          $pkg = "$pkgType $pkg"
        fi

        addPkg "$pkgMan" "$pkg"
      elif [ "$val" = "0" ]; then
        rmPkg "$pkgMan" "$pkg"
      fi
    done
  done
fi


# setup aspiesoft auto updates
if [ "$autoUpdates" = "y" -o "$autoUpdates" = "Y" -o "$autoUpdates" = "" -o "$autoUpdates" = " " ] ; then
  sudo mkdir -p /etc/aspiesoft-fedora-setup-updates
  sudo cp -rf ./assets/apps/aspiesoft-fedora-setup-updates/* /etc/aspiesoft-fedora-setup-updates
  sudo rm -f /etc/aspiesoft-fedora-setup-updates/aspiesoft-fedora-setup-updates.service
  sudo cp -f ./assets/apps/aspiesoft-fedora-setup-updates/aspiesoft-fedora-setup-updates.service "/etc/systemd/system"
  gitVer="$(curl --silent 'https://api.github.com/repos/AspieSoft/fedora-setup/releases/latest' | grep '\"tag_name\":' | sed -E 's/.*\"([^\"]+)\".*/\1/')"
  echo "$gitVer" | sudo tee "/etc/aspiesoft-fedora-setup-updates/version.txt"

  sudo systemctl daemon-reload
  sudo systemctl enable aspiesoft-fedora-setup-updates.service
  sudo systemctl start aspiesoft-fedora-setup-updates.service
fi

cleanup

# clean up and restart gnome
if [[ "$PWD" =~ fedora-setup/?$ ]]; then
  rm -rf "$PWD"
fi

echo "Install Finished!"

echo
echo "Ready To Restart Gnome!"
echo
read -n1 -p "Press any key to continue..." input ; echo >&2

# note: this will logout the user
killall -3 gnome-shell
