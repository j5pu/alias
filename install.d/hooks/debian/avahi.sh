#!/bin/sh

set -eu

RESTART=false
tmp="$(mktemp)"

compare() {
  tee "${tmp}" >/dev/null
  if [ "$(cat "${tmp}")" != "$(cat "$1")" ]; then
    sudo mv -v "${tmp}" "$1"
    RESTART=true
  fi
}

if ! dpkg -s avahi-daemon | grep -q "Status: install ok installed"; then
  sudo apt-get -qq update
  sudo apt-get -qq install -y avahi-daemon avahi-discover libnss-mdns
  RESTART=true
fi

pattern="#enable-reflector=no"
if grep "^${pattern}$" /etc/avahi/avahi-daemon.conf; then
  sed -i "s/^${pattern}$/enable-reflector=yes/"
  RESTART=true
fi

compare /etc/avahi/services/samba.service <<EOF
<?xml version="1.0" standalone='no'?><!--*-nxml-*-->
<!DOCTYPE service-group SYSTEM "avahi-service.dtd">

<service-group>
  <name replace-wildcards="yes">%h</name>
  <service>
    <type>_smb._tcp</type>
    <port>445</port>

  </service>
</service-group>
EOF

compare /etc/avahi/services/afpd.service <<EOF
<?xml version="1.0" standalone='no'?><!--*-nxml-*-->
<!DOCTYPE service-group SYSTEM "avahi-service.dtd">

<service-group>
  <name replace-wildcards="yes">%h</name>
  <service>
    <type>_afpovertcp._tcp</type>
    <port>548</port>

  </service>
</service-group>
EOF

compare /etc/avahi/services/vnc.service <<EOF
<?xml version="1.0" standalone='no'?><!--*-nxml-*-->
<!DOCTYPE service-group SYSTEM "avahi-service.dtd">

<service-group>
  <name replace-wildcards="yes">%h</name>
  <service>
    <type>_vnc._tcp</type>
    <port>5901</port>

  </service>
</service-group>
EOF

if $RESTART; then
  sudo systemctl daemon-reload
  sudo systemctl enable avahi-daemon
  sudo systemctl restart avahi-daemon
fi
