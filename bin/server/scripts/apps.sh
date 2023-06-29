#!/bin/bash

source ./bin/common.sh

# install common essentials
addPkg dnf neofetch

# install php
if [ "$(getPkgConfig dnf php)" != "0" ]; then
  addPkg dnf php php-cli phpunit composer
  addPkg dnf php-mysqli php-bcmath php-dba php-dom php-enchant php-fileinfo php-gd php-intl php-ldap php-mbstring php-mysqli php-mysqlnd php-odbc php-pdo php-pgsql php-phar php-posix php-pspell php-soap php-sockets php-sqlite3 php-sysvmsg php-sysvsem php-sysvshm php-tidy php-xmlreader php-xmlwriter php-xsl php-yaml php-zip php-memcache php-mailparse php-imagick php-igbinary php-redis php-curl php-cli php-common php-opcache
fi

# install nginx
if [ "$(addPkg dnf nginx)" = "1" ]; then
  sudo systemctl enable nginx.service
  sudo systemctl start nginx.service
fi

# install letsencrypt certbot
if [ "$(getPkgConfig snap certbot)" != "0" ]; then
  sudo snap install --classic certbot
  sudo ln -s /snap/bin/certbot /usr/bin/certbot
  sudo snap set certbot trust-plugin-with-root=ok
  sudo snap install certbot-dns-cloudflare
fi
