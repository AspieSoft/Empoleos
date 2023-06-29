#!/bin/bash

if ! [[ $(crontab -l) == *"# aspiesoft-clamav-scan"* ]] ; then
  crontab -l | { cat; echo '0 2 * * * sudo nice -n 15 clamscan -r --bell --move="/VirusScan/quarantine" --exclude-dir="/VirusScan/quarantine" --exclude-dir="/home/$USER/.clamtk/viruses" --exclude-dir="smb4k" --exclude-dir="/run/user/$USER/gvfs" --exclude-dir="/home/$USER/.gvfs" --exclude-dir=".thunderbird" --exclude-dir=".mozilla-thunderbird" --exclude-dir=".evolution" --exclude-dir="Mail" --exclude-dir="kmail" --exclude-dir="^/sys" / # aspiesoft-clamav-scan'; } | crontab -
fi

while true; do
  GOMEMLIMIT="$((1024 * 1024 * 200))" /etc/aspiesoft-clamav-scanner/linux-clamav-download-scanner
  sleep 1
done
