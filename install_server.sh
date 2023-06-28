#!/bin/bash

#todo: merge with install.sh and "--server" option

cd $(dirname "$0")
dir="$PWD"


# verify checksums
gitSum=$(curl --silent "https://raw.githubusercontent.com/AspieSoft/Empoleos/master/install_server.sh" | sha256sum | sed -E 's/([a-zA-Z0-9]+).*$/\1/')
sum=$(sha256sum "install_server.sh" | sed -E 's/([a-zA-Z0-9]+).*$/\1/')
if ! [ "$sum" = "$gitSum" ]; then
  echo "error: checksum failed!"
  exit
fi

gitSum=$(curl --silent "https://raw.githubusercontent.com/AspieSoft/Empoleos/master/bin/common.sh" | sha256sum | sed -E 's/([a-zA-Z0-9]+).*$/\1/')
sum=$(sha256sum "bin/common.sh" | sed -E 's/([a-zA-Z0-9]+).*$/\1/')
if ! [ "$sum" = "$gitSum" ]; then
  echo "error: checksum failed!"
  exit
fi


# add bash dependencies
source ./bin/common.sh


function loadConfigFile {
  #todo: handle https requests
  if ! [ "$configFile" = "" ] && ! [ "$hasConf" = "1" ]; then
    if test -f "$configFile"; then
      hasConf="1"
      eval $(parse_yaml "$configFile" "empoleosCONF_")
    else
      hasConf="0"
    fi
  elif [ "$configFile" = "" ]; then
    hasConf="0"
  fi
}


autoUpdates="y"

for opt in "$@"; do
  if [ "$opt" = "-y" ]; then
    autoYes="1"
  elif [[ "$opt" =~ "--config=".* ]]; then
    configFile="${opt/--config=/}"
    if [[ "$configFile" =~ "http://".* ]]; then
      if [[ "$configFile" =~ "http://localhost:".* ]] || [[ "$configFile" =~ "http://127.0.0.1:".* ]]; then
        continue
      fi

      echo "error: config must be secure. (use https instead of http)"
      configFile=""
    fi
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
    while true; do
      echo "Choose a config file you would like to use"
      echo "or leave blank for default setup"
      read -p "Config File (yml): " configFile

      if [[ "$configFile" =~ "http://".* ]]; then
        if [[ "$configFile" =~ "http://localhost:".* ]] || [[ "$configFile" =~ "http://127.0.0.1:".* ]]; then
          break
        fi

        echo "error: config must be secure. (use https instead of http)"
        configFile=""
        continue
      fi

      break
    done
  fi

  # load config file
  loadConfigFile

  if [ "$empoleosCONF_auto_updates" = "no" -o "$empoleosCONF_auto_updates" = "false" ]; then
    autoUpdates="n"
  elif ! [ "$empoleosCONF_auto_updates" = "yes" -o "$empoleosCONF_auto_updates" = "true" ]; then
    read -n1 -p "Would you like automatic updates to be pulled from the github repo (Y/n)? " autoUpdates
  fi
elif [ "$configFile" = "" ]; then
  if test -f empoleos.yml; then
    configFile="empoleos.yml"
  fi
fi


# load config file if not loaded
loadConfigFile


echo "Starting Install..."
echo


function cleanup {
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


# verify script checksums
for file in bin/scripts/*.sh; do
  gitVerify "$file"
done


# run scripts
bash ./bin/scripts/repos.sh
bash ./bin/scripts/fix.sh
bash ./bin/server/scripts/preformance.sh

bash ./bin/scripts/programing-languages.sh
bash ./bin/server/scripts/security.sh

bash ./bin/server/scripts/apps.sh

bash ./bin/scripts/shortcuts.sh


# handle config packages
if [ "$hasConf" = "1" ]; then
  pkgManUsed=""
  for pkgMan in $empoleosCONF_; do
    if [[ "$pkgMan" =~ "flatpak_".* ]] || [ "$pkgMan" = "dnf" -o "$pkgMan" = "snap" ]; then
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
    fi
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

# clean up
if [[ "$PWD" =~ fedora-setup/?$ ]]; then
  rm -rf "$PWD"
fi

echo "Install Finished!"
