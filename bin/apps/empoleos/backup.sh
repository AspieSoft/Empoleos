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


echo "starting backup for empoleos"

gio rename "$backupFiles/config.yml" "config.yml.back"
gio rename "$backupFiles/enc.key" "enc.key.back"
gio rename "$backupFiles/home.zip" "home.zip.back"

gio copy "$dir/config.yml" "$backupFiles/config.yml"

tmpDir="$(mktemp -d)"

backupFiles="$(cat backup.txt)"

tmpPassWD="$(pwgen -scnyB -r \" 512 1)"

cd "$HOME"
bash "$dir/bin/copy-limit.sh" "." "$tmpDir/home.zip" "$tmpPassWD"
cd "$dir"

echo "$tmpPassWD" > "$tmpDir/enc.key"
gio copy "$tmpDir/enc.key" "$backupFiles/enc.key"
rm -f "$tmpDir/enc.key"

gio copy "$tmpDir/home.zip" "$backupFiles/home.zip"
tmpPassWD=""

gio rename "$backupFiles/config.yml.back"
gio remove "$backupFiles/enc.key.back"
gio remove "$backupFiles/home.zip.back"
