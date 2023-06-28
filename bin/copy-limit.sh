#!/bin/bash

for dir in $(ls "$1" -A); do
  if ! [ "$dir" = ".cache" -o "$dir" = ".local" -o "$dir" = ".gnome" -o "$dir" = ".dotnet" -o "$dir" = ".pki" -o "$dir" = ".redhat" -o "$dir" = ".bash_history" -o "$dir" = "go" ] && ! [[ "$dir" =~ "cache" ]] && ! [[ "$dir" =~ "Cache" ]] && ! [[ "$dir" =~ "tmp" ]] && ! [[ "$dir" =~ "Tmp" ]]; then
    if test -d "$1/$dir"; then
      bash "$0" "$1/$dir" "$2" "$3"
    else
      nice -n 15 zip -grye "$2" "$1/$dir" -P "$3"
    fi
  fi
done
