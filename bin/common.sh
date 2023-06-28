#!/bin/bash

function hasPkg {
  if [ "$(sudo which "$1" 2>/dev/null)" != "" ]; then
    echo 1
  else
    echo 0
  fi
}

function addPkg {
  if [ "$1" = "flatpak" -o "$1" = "flatpack" ]; then
    pkgMan="flatpak"
    pkgType="$2"
    pkgList="$2"
    pkgCheck="${@:3}"
  else
    pkgMan="$1"
    pkgCheck="${@:2}"
  fi

  for pkg in $pkgCheck; do
    if [ "$(hasPackage $pkg)" = "0" ]; then
      pkgConf="$(getPkgConfig $pkgMan $pkg $pkgType)"

      # add package to list
      if [ "$pkgConf" = "1" -o "$pkgConf" = "2" ]; then
        if [ "$pkgList" = "" ]; then
          pkgList="$pkg"
        else
          pkgList="$pkgList $pkg"
        fi
      fi
    fi
  done

  if [ "$pkgList" != "" ] || [ "$pkgMan" = "flatpak" -a "${pkgList/$pkgType /}" ]; then
    if [ "$1" = "dnf" ]; then
      sudo dnf -y install $pkgList
    elif [ "$1" = "flatpak" -o "$1" = "flatpack" ]; then
      sudo flatpak install -y $pkgList
    elif [ "$1" = "snap" ]; then
      sudo snap install $pkgList
    fi

    echo 1
  else
    echo 0
  fi
}

function rmPkg {
  if [ "$1" = "flatpak" -o "$1" = "flatpack" ]; then
    pkgMan="flatpak"
    pkgType="$2"
    pkgCheck="${@:3}"
  else
    pkgMan="$1"
    pkgCheck="${@:2}"
  fi

  for pkg in $pkgCheck; do
    if [ "$(hasPackage $pkg)" = "1" ]; then
      pkgConf="$(getPkgConfig $pkgMan $pkg $pkgType)"

      # add package to list
      if [ "$pkgConf" = "0" -o "$pkgConf" = "2" ]; then
        if [ "$pkgList" = "" ]; then
          pkgList="$pkg"
        else
          pkgList="$pkgList $pkg"
        fi
      fi
    fi
  done

  if [ "$pkgList" != "" ] || [ "$pkgMan" = "flatpak" -a "${pkgList/$pkgType /}" ]; then
    if [ "$1" = "dnf" ]; then
      sudo dnf -y remove $pkgList
    elif [ "$1" = "flatpak" -o "$1" = "flatpack" ]; then
      sudo flatpak uninstall -y $pkgList
    elif [ "$1" = "snap" ]; then
      sudo snap remove --purge $pkgList
    fi

    echo 1
  else
    echo 0
  fi
}

# inputs: $pkgMan, $pkg, $pkgType (flatpak)
# outputs: 0 = remove, 1 = add, 2 = default (not specified)
function getPkgConfig {
  if [ "$hasConf" = "1" ]; then
    confVarPkg=$(echo "$2" | sed -e 's/-/__l__/g' -e 's/\./__d__/g')
    if [ "$1" = "flatpak" ]; then
      confVar="empoleosCONF_${1}_${3}_${confVarPkg}"
    else
      confVar="empoleosCONF_${1}_${confVarPkg}"
    fi

    if [ "${!confVar}" = "yes" -o "${!confVar}" = "true" -o "${!confVar}" = "add" ]; then
      echo 1
    elif [ "${!confVar}" = "no" -o "${!confVar}" = "false" -o "${!confVar}" = "remove" -o "${!confVar}" = "rm" ]; then
      echo 0
    else
      echo 2
    fi
  else
    echo 2
  fi
}


function parse_yaml {
  local prefix=$2
  local s='[[:space:]]*' w='[a-zA-Z0-9_]*' fs=$(echo @|tr @ '\034')
  sed -e "s|-|__l__|g" -e "s|\.|__d__|g" \
    -ne "s|^\($s\):|\1|" \
    -e "s|^\($s\)\($w\)$s:$s[\"']\(.*\)[\"']$s\$|\1$fs\2$fs\3|p" \
    -e "s|^\($s\)\($w\)$s:$s\(.*\)$s\$|\1$fs\2$fs\3|p"  $1 |
  awk -F$fs '{
    indent = length($1)/2;
    vname[indent] = $2;
    for (i in vname) {if (i > indent) {delete vname[i]}}
    if (length($3) > 0) {
      vn=""; for (i=0; i<indent; i++) {
        vn=(vn)(vname[i])("_")
      }

      printf("%1$s%2$s%3$s=\"%4$s\"\n", "'$prefix'",vn, $2, $3);
      printf("%1$s%2$s=\"${%1$s%2$s} $(echo \"%3$s\" | sed -e \"s/_$//g\")\"\n", "'$prefix'",vn, $2, $3);
      printf("%1$s=\"${%1$s} $(echo \"%2$s\" | sed -e \"s/_$//g\")\"\n", "'$prefix'",vn, $2, $3);
    }
  }'
}


function gitVerify {
  gitSum=$(curl --silent "https://raw.githubusercontent.com/AspieSoft/Empoleos/master/$1" | sha256sum | sed -E 's/([a-zA-Z0-9]+).*$/\1/')
  sum=$(sha256sum "$1" | sed -E 's/([a-zA-Z0-9]+).*$/\1/')
  if ! [ "$sum" = "$gitSum" ]; then
    echo "error: checksum failed!"
    exit
  fi
}
