#!/bin/sh
set -e
# ost-config.php lives on the persistent volume so the web installer's output survives restarts.
CFG=/data/ost-config.php
[ -f "$CFG" ] || { cp /var/www/html/include/ost-config.sample.php "$CFG"; chown www-data:www-data "$CFG"; chmod 0666 "$CFG"; }
ln -sf "$CFG" /var/www/html/include/ost-config.php
# Once installed (placeholders gone) lock the config down and remove the installer.
if ! grep -q '%CONFIG-DBHOST' "$CFG"; then
  chmod 0644 "$CFG"
  rm -rf /var/www/html/setup
fi
exec docker-php-entrypoint "$@"
