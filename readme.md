# Fedora Setup

Completely Transform a new Fedora WorkStation install.

To put things simply, these changes are not big enough to make a full linux distro, but this script tries to act like one.
This script also adds an auto update checker, to automatically add in new features when a new version is released on the [github repo](https://github.com/AspieSoft/Empoleos).

Note: Creating a backup of your distro before running this script is recommended.

## Installasion

```shell
git clone https://github.com/AspieSoft/Empoleos.git && Empoleos/install.sh
```

## Install Server (Optional)

```shell
git clone https://github.com/AspieSoft/Empoleos.git && Empoleos/install.sh --server
```

## Install With Config

```shell
git clone https://github.com/AspieSoft/Empoleos.git && Empoleos/install.sh --config="my/config-file.yml"

# or a url

git clone https://github.com/AspieSoft/Empoleos.git && Empoleos/install.sh --config="https://example.com/my-config.yml"
```
