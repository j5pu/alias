#!/bin/sh

set -eu

REBOOT=false
tmp="$(mktemp)"

compare() {
  tee "${tmp}" >/dev/null
  if [ "$(cat "${tmp}")" != "$(cat "$1")" ]; then
    sudo mv -v "${tmp}" "$1"
    sudo systemctl daemon-reload
    sudo systemctl enable x11vnc
    sudo systemctl restart x11vnc
  fi
}

if ! dpkg -s x11vnc | grep -q "Status: install ok installed"; then
  sudo apt-get -qq update
  sudo apt-get -qq install -y x11vnc
fi

sudo mkdir -p /etc/systemd/system
sudo x11vnc -storepasswd "$(cat /etc/password)" /etc/x11vnc.passwd

compare /etc/systemd/system/x11vnc.service <<EOF
[Unit]
Description=X11 VNC Remote Desktop Service
Requires=display-manager.service
After=syslog.target network-online.target ##optional for better performance
Wants=syslog.target network-online.target ##optional for better performance

[Service]
ExecStart=/usr/bin/x11vnc -avahi -norc -forever -shared\
 -display :0 -rfbauth /etc/x11vnc.passwd -auth guess -o /var/log/x11vnc.log
ExecStop=/usr/bin/x11vnc -R stop
Restart=on-failure
RestartSec=2

[Install]
WantedBy=multi-user.target
EOF
