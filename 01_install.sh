#!/bin/bash

# Source/Docs: github.com/max675/raspicam-streamer
# (c) 2015 by max675


# Make sure only root can run our script
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi


echo "Installieren von VLC"
export DEBIAN_FRONTEND=noninteractive
apt-get -q -y install vlc

echo "Installieren des Streaming-Services"
apt-get -q -y install daemontools daemontools-run
useradd -M -d /nohome -s /bin/false -u 521 -g nogroup vlcd

mkdir /var/log/vlcd
chown vlcd /var/log/vlcd
mkdir -p /etc/service/vlcd /etc/service/vlcd/log

cp -v instfiles/vlcd/picam2.sh /etc/service/vlcd/
cp -v instfiles/vlcd/run /etc/service/vlcd/
cp -v instfiles/vlcd/log-run /etc/service/vlcd/log/run

chmod +x /etc/service/vlcd/run /etc/service/vlcd/log/run

echo 'SUBSYSTEM=="vchiq",GROUP="video",MODE="0660"' > /etc/udev/rules.d/10-vchiq-permissions.rules
usermod -a -G video vlcd

# Service starten
svc -u /etc/service/vlcd

