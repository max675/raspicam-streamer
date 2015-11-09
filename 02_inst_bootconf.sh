#!/bin/bash

# Source/Docs: github.com/max675/raspicam-streamer
# (c) 2015 by max675

# Make sure only root can run our script
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

# Installiert Konfig Tools
TGDIR="/boot"
mkdir -p $TGDIR

# Dateien bereitstellen
cp -v /etc/network/interfaces $TGDIR
cp -v /etc/service/vlcd/picam2.sh $TGDIR
touch $TGDIR/enable_ssh

cp -v instfiles/init.d/copyconf /etc/init.d/
cp -v instfiles/init.d/managessh /etc/init.d/

chmod 0755 /etc/init.d/copyconf
chmod 0755 /etc/init.d/managessh

update-rc.d copyconf defaults
# Möglicherweise Bug hier: 
update-rc.d copyconf defaults


