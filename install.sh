#!/bin/bash

cd $(dirname "$0")
dir="$PWD"


# verify checksums
gitSum=$(curl --silent "https://raw.githubusercontent.com/AspieSoft/Empoleos/master/install.sh" | sha256sum | sed -E 's/([a-zA-Z0-9]+).*$/\1/')
sum=$(cat "install.sh" | sha256sum | sed -E 's/([a-zA-Z0-9]+).*$/\1/')
if ! [ "$sum" = "$gitSum" ]; then
  echo "error: checksum failed!"
  exit
fi

gitSum=$(curl --silent "https://raw.githubusercontent.com/AspieSoft/Empoleos/master/bin/common.sh" | sha256sum | sed -E 's/([a-zA-Z0-9]+).*$/\1/')
sum=$(cat "bin/common.sh" | sha256sum | sed -E 's/([a-zA-Z0-9]+).*$/\1/')
if ! [ "$sum" = "$gitSum" ]; then
  echo "error: checksum failed!"
  exit
fi


# add bash dependencies
source ./bin/common.sh

# get distro base
if [ "$(cat /proc/version | grep 'Red Hat')" ] && [ "$(sudo which dnf 2>/dev/null)" != "" -o "$(sudo which yum 2>/dev/null)" != "" -o "$(sudo which rpm-ostree 2>/dev/null)" != "" -o "$(sudo which rpm 2>/dev/null)" != "" ]; then
  export DISTRO_BASE="fedora"
elif [ "$(cat /proc/version | grep 'Debian')" ] && [ "$(sudo which apt 2>/dev/null)" != "" -o "$(sudo which apt-get 2>/dev/null)" != "" -o "$(sudo which nala 2>/dev/null)" != "" -o "$(sudo which dpkg 2>/dev/null)" != "" ]; then
  export DISTRO_BASE="debian"
elif [ "$(cat /proc/version | grep 'Ubuntu')" ] && [ "$(sudo which apt 2>/dev/null)" != "" -o "$(sudo which apt-get 2>/dev/null)" != "" -o "$(sudo which nala 2>/dev/null)" != "" -o "$(sudo which dpkg 2>/dev/null)" != "" ]; then
  export DISTRO_BASE="ubuntu"
else
  echo "error: your linux distro is not yet supported"
  exit
fi

eval $(parse_yaml "./bin/distroPkgMap.yml" "distroPkgMap_")


tmpDir="$(mktemp -d)"


function loadConfigFile {
  if ! [ "$configFile" = "" ] && ! [ "$hasConf" = "1" ]; then
    if [[ "$configFile" =~ "https://".* ]]; then
      wget --https-only -i "$configFile" -O "$tmpDir/url-config.yml"
      configFile="$tmpDir/url-config.yml"
      hasConf="1"
      eval $(parse_yaml "$configFile" "empoleosCONF_")
    elif test -f "$configFile"; then
      hasConf="1"
      eval $(parse_yaml "$configFile" "empoleosCONF_")
    else
      hasConf="0"
    fi
  elif [ "$configFile" = "" ]; then
    hasConf="0"
  fi
}


function askForConfigFile {
  while true; do
    echo
    echo "Choose a config file you would like to use"
    echo "or leave blank for default setup"
    echo "you may also enter your email for automatic cloud save backups (including your home directory)"
    echo "you can enter a url to load a config file from the web (ie: 'https://example.com/empoleos-config.yml')"
    read -p "Config File (yml): " configFile

    if [[ "$configFile" =~ "http://".* ]]; then
      if [[ "$configFile" =~ "http://localhost:".* ]] || [[ "$configFile" =~ "http://127.0.0.1:".* ]]; then
        break
      fi

      echo "error: config must be secure. (use https instead of http)"
      configFile=""
      continue
    fi

    echo

    #todo: add support for other online account types
    if [[ "$configFile" =~ .*"@gmail.com" ]]; then
      if [ "$(gio info "google-drive://$configFile/My Drive")" = "" ]; then
        echo "error: you must first sign into that account with gnome online accounts, and open a google drive folder with the file manager"
        configFile=""
        continue
      fi

      fileList=$(gio list "google-drive://$configFile/My Drive/EmpoleosBackups" -ud)
      if [ "$fileList" = "" ]; then
        gio mkdir "google-drive://$configFile/My Drive/EmpoleosBackups"
        echo
        read -p "New Cloud Backup: " configFileName
        if [ "$configFileName" = "" ]; then
          configFile=""
          continue
        fi

        while true; do
          echo
          read -s -p "New Passcode: " backupPWD
          echo
          read -s -p "Repeat Passcode: " backupRepeatPWD
          echo
          if [ "$backupPWD" = "" ]; then
            echo "error: passcode cannot be blank"
            continue
          elif [ "$backupPWD" = "$backupRepeatPWD" ]; then
            backupRepeatPWD=""
            break
          fi
          echo "error: passcodes did not match"
        done

        backupPWD="$(echo "$backupPWD" | sha256sum | sed -E 's/([a-zA-Z0-9]+).*$/\1/' | sed -E "s/([a-zA-Z0-9]{10})[a-zA-Z0-9]{3}/\1/g")"
      else
        for file in $fileList; do
          echo "$(echo $file | sed -e 's#^google-drive://[^\\/]*/My[%20 ]*Drive/##i' -e 's#%20# #g')"
        done

        echo
        echo "(Or Enter A New Name To Create A New Cloud Backup)"
        read -p "Choose Cloud Backup: " configFileName
        if [ "$configFileName" = "" ]; then
          configFile=""
          continue
        fi
      fi

      backupFiles="google-drive://$configFile/My Drive/EmpoleosBackups/$configFileName"
      listTest=$(gio list "$backupFiles" -ud)
      if [ "$listTest" = "" ]; then
        listTest=""
        gio mkdir "$backupFiles"
        configFileNew=1

        while true; do
          echo
          read -s -p "New Passcode: " backupPWD
          echo
          read -s -p "Repeat Passcode: " backupRepeatPWD
          echo
          if [ "$backupPWD" = "" ]; then
            echo "error: passcode cannot be blank"
            continue
          elif [ "$backupPWD" = "$backupRepeatPWD" ]; then
            backupRepeatPWD=""
            break
          fi
          echo "error: passcodes did not match"
        done

        backupPWD="$(echo "$backupPWD" | sha256sum | sed -E 's/([a-zA-Z0-9]+).*$/\1/' | sed -E "s/([a-zA-Z0-9]{10})[a-zA-Z0-9]{3}/\1/g")"
        break
      fi

      listTest=""
      gio copy "$backupFiles/config.yml" "$tmpDir/config.yml"
      configFile="$tmpDir/config.yml"

      gio copy "$backupFiles/pass.key" "$tmpDir/pass.key"

      while true; do
          echo
          read -s -p "Enter Passcode: " backupPWD
          echo
          if [ "$backupPWD" = "" ]; then
            echo "error: passcode cannot be blank"
            continue
          else
            backupPWD="$(echo "$backupPWD" | sha256sum | sed -E 's/([a-zA-Z0-9]+).*$/\1/' | sed -E "s/([a-zA-Z0-9]{10})[a-zA-Z0-9]{3}/\1/g")"

            # verify passcode (this only checks if the passcode might be correct, and does not affect security, since the passcode is verified in a more complex way later, before being used)
            passKey="$(echo "$backupPWD" | sha256sum | sed -E 's/([a-zA-Z0-9]+).*$/\1/' | sed -E "s/([a-zA-Z0-9]{7})[a-zA-Z0-9]{5}/\1/g")"
            if [ "$(cat "$tmpDir/pass.key")" = "" -o "$(cat "$tmpDir/pass.key")" = "$(echo "$backupPWD" | sha256sum | sed -E 's/([a-zA-Z0-9]+).*$/\1/' | sed -E "s/([a-zA-Z0-9]{7})[a-zA-Z0-9]{5}/\1/g")" ]; then
              rm -f "$tmpDir/pass.key"
              break
            fi
            echo "error: incorrect passcode"
          fi
        done
    elif [[ "$configFile" =~ .*"@".* ]]; then
      echo "error: that account type is not yet supported"
      configFile=""
      continue
    fi

    break
  done
}


function helpInfo {
  echo
  echo '-h, --help, -?: this list'
  echo
  echo '-y: autoyes'
  echo
  echo '--config: "path/to/congig.yml" || "https://example.com/config.yml"'
  echo
  echo '--server: enable install for servers'
  echo
  echo '--boring: disable fun theme modifications for desktop install (does not apply to server install)'
  echo
}


autoUpdates="y"

serverMode="n"
boringMode="n"

for opt in "$@"; do
  if [ "$opt" = "-y" ]; then
    autoYes="1"
  elif [ "$opt" = "-h" -o "$opt" = "--help" -o "$opt" = "-?" ]; then
    helpInfo
    exit
  elif [ "$opt" = "--server" ]; then
    serverMode="y"
  elif [ "$opt" = "--boring" ]; then
    boringMode="y"
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
    askForConfigFile
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


if [ "$empoleosCONF_server" = "yes" -o "$empoleosCONF_server" = "true" ]; then
  serverMode="y"
fi

if [ "$empoleosCONF_boring" = "yes" -o "$empoleosCONF_boring" = "true" ]; then
  boringMode="y"
fi


echo "Starting Install..."
echo


function cleanup {
  if ! [ "$serverMode" = "y" ]; then
    # reset login timeout
    sudo sed -r -i 's/^Defaults([\t ]+)(.*)env_reset(.*), (timestamp_timeout=1801,?\s*)+$/Defaults\1\2env_reset\3/m' /etc/sudoers &>/dev/null

    # enable sleep
    sudo systemctl --runtime unmask sleep.target suspend.target hibernate.target hybrid-sleep.target &>/dev/null
    gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type 'suspend' &>/dev/null

    # enable auto updates
    gsettings set org.gnome.software download-updates true

    # enable auto suspend
    sudo perl -0777 -i -pe 's/#AspieSoft-TEMP-START(.*)#AspieSoft-TEMP-END//s' /etc/systemd/logind.conf &>/dev/null
  fi

  backupPWD=""
  backupRepeatPWD=""
  tmpPassWD=""

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


if ! [ "$serverMode" = "y" ]; then
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
fi




# verify script checksums
for file in bin/scripts/*.sh; do
  gitVerify "$file"
done


# run scripts
if [ "$DISTRO_BASE" = "fedora" ]; then
  bash ./bin/scripts/repos.sh
elif [ "$DISTRO_BASE" = "ubuntu" -o "$DISTRO_BASE" = "debian" ]; then
  bash ./bin/scripts/apt/repos.sh
fi

bash ./bin/scripts/fix.sh

if [ "$serverMode" = "y" ]; then
  bash ./bin/server/scripts/preformance.sh
else
  bash ./bin/scripts/preformance.sh
fi

bash ./bin/scripts/programing-languages.sh
bash ./bin/scripts/security.sh "$serverMode"

if [ "$serverMode" = "y" ]; then
  bash ./bin/server/scripts/apps.sh
else
  bash ./bin/scripts/apps.sh
fi

bash ./bin/scripts/shortcuts.sh

if ! [ "$serverMode" = "y" ]; then
  bash ./bin/scripts/theme.sh "$boringMode"
fi


# handle config packages
if [ "$hasConf" = "1" ]; then
  pkgManUsed=""
  for pkgMan in $empoleosCONF_; do
    if [[ "$pkgMan" =~ "flatpak_".* ]] || [ "$pkgMan" = "dnf" -a "$DISTRO_BASE" = "fedora" ] || [ "$pkgMan" = "apt" -a "$DISTRO_BASE" = "ubuntu" ] || [ "$pkgMan" = "apt" -a "$DISTRO_BASE" = "debian" ] || [ "$pkgMan" = "snap" ]; then
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

        if [ "$pkg" == "_remote" ]; then
          pkgKey="${key}${pkg}"
          sudo flatpak remote-add --if-not-exists "$pkgType" "${!pkgKey}"
          continue
        fi

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


# setup auto updates
if [ "$autoUpdates" = "y" -o "$autoUpdates" = "Y" -o "$autoUpdates" = "" -o "$autoUpdates" = " " ] ; then
  if [ "$configFileNew" = "1" ]; then
    echo 'auto_updates: yes' >> "$tmpDir/config.yml"
  fi

  sudo sed -r -i 's/^#auto_updates=$/auto_updates=/m' "$dir/bin/apps/empoleos/init.sh"
else if [ "$configFileNew" = "1" ]; then
  echo 'auto_updates: no' >> "$tmpDir/config.yml"
fi

# setup auto backups
if ! [ "$backupFiles" = "" ]; then
  if [ "$configFileNew" = "1" ]; then
    gio copy "$tmpDir/config.yml" "$backupFiles/config.yml"

    tmpPassWD="$(pwgen -scnyB -r "\\\"'\`\$!%" 512 1)"

    cd "$HOME"
    bash "$dir/bin/copy-limit.sh" "." "$tmpDir/home.zip" "$backupPWD-$tmpPassWD"
    cd "$dir"

    echo "$tmpPassWD" > "$tmpDir/enc.key"
    gio copy "$tmpDir/enc.key" "$backupFiles/enc.key"
    rm -f "$tmpDir/enc.key"

    gio copy "$tmpDir/home.zip" "$backupFiles/home.zip"
    tmpPassWD=""

    echo "$(echo "$backupPWD" | sha256sum | sed -E 's/([a-zA-Z0-9]+).*$/\1/' | sed -E "s/([a-zA-Z0-9]{7})[a-zA-Z0-9]{5}/\1/g")" > "$tmpDir/pass.key"
    gio copy "$tmpDir/pass.key" "$backupFiles/pass.key"
    rm -f "$tmpDir/pass.key"
  else
    gio copy "$backupFiles/home.zip" "$tmpDir/home.zip"

    gio copy "$backupFiles/enc.key" "$tmpDir/enc.key"
    tmpPassWD="$(cat $tmpDir/enc.key)"
    rm -f "$tmpDir/enc.key"

    unzip -o -P "$backupPWD-$tmpPassWD" "$tmpDir/home.zip" -d "$HOME"
  fi

  sudo sed -r -i 's/^#auto_backups=$/auto_backups=/m' "$dir/bin/apps/empoleos/init.sh"
  echo "$backupFiles" | sudo tee "$HOME/.empoleos-backup.url"
  echo "$backupPWD" | sudo tee "$HOME/.empoleos-backup.key"
  backupPWD=""
fi

if [ "$serverMode" = "y" ]; then
  sudo sed -r -i 's/^#is_server=$/is_server=/m' "$dir/bin/apps/empoleos/update.sh"
fi

sudo mkdir -p /etc/empoleos
sudo cp -rf ./bin/apps/empoleos/* /etc/empoleos
sudo rm -f /etc/empoleos/empoleos.service
sudo cp -f ./bin/apps/empoleos/empoleos.service "/etc/systemd/system"
gitVer="$(curl --silent 'https://api.github.com/repos/AspieSoft/Empoleos/releases/latest' | grep '\"tag_name\":' | sed -E 's/.*\"([^\"]+)\".*/\1/')"
echo "$gitVer" | sudo tee "/etc/empoleos/version.txt"

sudo systemctl daemon-reload
sudo systemctl enable empoleos.service
sudo systemctl start empoleos.service


# set bash profile $PS1
if [ "$DISTRO_BASE" = "fedora" ]; then
  if ! [ -f "/etc/profile.d/bash_ps.sh" ]; then
    echo "if [ "$PS1" ]; then" | sudo tee -a /etc/profile.d/bash_ps.sh &>/dev/null
    echo '  PS1="\[\e[m\][\[\e[1;32m\]\u@\h\[\e[m\]:\[\e[1;34m\]\w\[\e[m\]]\[\e[0;31m\](\$?)\[\e[1;0m\]\\$ \[\e[m\]"' | sudo tee -a /etc/profile.d/bash_ps.sh &>/dev/null
    echo "fi" | sudo tee -a /etc/profile.d/bash_ps.sh &>/dev/null
  fi
fi


# clean up
cleanup

if [[ "$PWD" =~ empoleos/?$ ]]; then
  rm -rf "$PWD"
fi

dnfClean
dnfUpdate "upgrade"

echo "Install Finished!"


# restart gnome
if ! [ "$serverMode" = "y" ]; then
  echo
  echo "Ready To Restart Gnome!"
  echo
  read -n1 -p "Press any key to continue..." input ; echo >&2

  # note: this will logout the user
  killall -3 gnome-shell
fi
