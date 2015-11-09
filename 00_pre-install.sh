#!/bin/bash

# Source/Docs: github.com/max675/raspicam-streamer
# (c) 2015 by max675

# Make sure only root can run our script
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

# Tastatur Layout
dpkg-reconfigure keyboard-configuration
invoke-rc.d keyboard-setup start

dpkg-reconfigure locales
dpkg-reconfigure tzdata

# SSH aktivieren
/usr/sbin/update-rc.d ssh enable
invoke-rc.d ssh start

# Updates installieren
export DEBIAN_FRONTEND=noninteractive
apt-get -q -y update 
apt-get -q -y install
apt-get -q -y install vim

. raspi-config-func.sh
set_camera 1

