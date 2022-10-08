#!/bin/sh

set -eu
sudo nano /etc/avahi/avahi-daemon.conf
# uncomment
#enable-reflector=no

RESTART=false
tmp="$(mktemp)"

compare() {
  tee "${tmp}" >/dev/null
  if [ "$(cat "${tmp}")" != "$(cat "$1")" ]; then
    sudo mv -v "${tmp}" "$1"
    RESTART=true
  fi
}

if ! dpkg -s samba| grep -q "Status: install ok installed"; then
  sudo apt-get -qq update
  sudo apt-get -qq install -y samba smbclient cifs-utils samba-common-bin
  RESTART=true
fi
sudo smbpasswd -a j5pu -n


if $RESTART; then
  sudo systemctl daemon-reload
  sudo systemctl enable nmbd
  sudo systemctl restart nmbd
fi
