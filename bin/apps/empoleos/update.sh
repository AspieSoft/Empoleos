#!/bin/bash

cd $(dirname "$0")
dir="$PWD"


# wait for wifi (timeout=5min)
tries=0
while [ "$(ping -c1 www.google.com 2>/dev/null)" == "" ]; do
  if [ "$tries" -gt "30" ]; then
    echo "error: failed to connect to wifi"
    exit
  fi

  tries=$((tries+1))
  echo "waiting for wifi..."
  sleep 10
done

sleep 1


echo "starting update for empoleos"

gitVer="$(curl --silent 'https://api.github.com/repos/AspieSoft/Empoleos/releases/latest' | grep '\"tag_name\":' | sed -E 's/.*\"([^\"]+)\".*/\1/')"

if [ "$gitVer" = "" ]; then
  echo "error: failed to connect to github!"
  exit
fi

ver="$(cat version.txt)"

if [ "$ver" = "$gitVer" ]; then
  echo "already up to date!"
  exit
fi

echo "updating $ver -> $gitVer"

git clone https://github.com/AspieSoft/Empoleos.git

cd Empoleos

for file in bin/scripts/*.sh; do
  gitSum=$(curl --silent "https://raw.githubusercontent.com/AspieSoft/Empoleos/master/$file" | sha256sum | sed -E 's/([a-zA-Z0-9]+).*$/\1/')
  sum=$(sha256sum "$file" | sed -E 's/([a-zA-Z0-9]+).*$/\1/')
  if ! [ "$sum" = "$gitSum" ]; then
    echo "error: checksum failed!"
    exit
  fi
done

sudo nice -n 15 clamscan && sudo clamscan -r --bell --move="/VirusScan/quarantine" --exclude-dir="/VirusScan/quarantine" "$PWD/assets"

cd bin/updates
readarray -d '' fileList < <(printf '%s\0' *.sh | sort -zV)
cd ../../

for file in "${fileList[@]}"; do
  fileVer=(${file//./ })
  if ! [ "$ver" == "${fileVer[0]}.${fileVer[1]}.${fileVer[2]}" ]; then
    verN=(${ver//./ })
    if [ "${verN[0]}" -le "${fileVer[0]}" ] && [ "${verN[1]}" -le "${fileVer[1]}" ] && [ "${verN[2]}" -le "${fileVer[2]}" ]; then
      gitSum=$(curl --silent "https://raw.githubusercontent.com/AspieSoft/Empoleos/master/bin/updates/$file" | sha256sum | sed -E 's/([a-zA-Z0-9]+).*$/\1/')
      sum=$(sha256sum "bin/updates/$file" | sed -E 's/([a-zA-Z0-9]+).*$/\1/')
      if [ "$sum" = "$gitSum" ]; then
        echo "updating $ver -> ${fileVer[0]}.${fileVer[1]}.${fileVer[2]}"
        sudo bash "./bin/updates/$file"
        ver="${fileVer[0]}.${fileVer[1]}.${fileVer[2]}"
      else
        echo "checksum failed for update ${fileVer[0]}.${fileVer[1]}.${fileVer[2]}"
      fi
    fi
  fi
done

cd "$dir"
rm -rf Empoleos
echo "$ver" | sudo tee "version.txt"

if [ "$ver" = "$gitVer" ]; then
  echo "now up to date!"
else
  echo "failed to finish update!"
fi

echo "updated to $ver"
echo "latest $getVer"
