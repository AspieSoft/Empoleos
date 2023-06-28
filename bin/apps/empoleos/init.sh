#!/bin/bash

#auto_updates="1"
#auto_backups="1"

if [ "$auto_updates" = "1" ]; then
  if ! [[ $(crontab -l) == *"#empoleos-updates"* ]] ; then
    crontab -l | { cat; echo '0 2 * * * sudo bash /etc/empoleos/update.sh #empoleos-updates'; } | crontab -
  fi

  sudo bash /etc/empoleos/update.sh &
fi

if [ "$auto_backups" = "1" ]; then
  if ! [[ $(crontab -l) == *"#empoleos-backups"* ]] ; then
    crontab -l | { cat; echo '0 2 * * * sudo bash /etc/empoleos/backup.sh #empoleos-backups'; } | crontab -
  fi

  sudo bash /etc/empoleos/backup.sh &
fi
