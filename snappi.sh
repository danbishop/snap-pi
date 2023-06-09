#!/bin/bash

# sudo check
if [ "$EUID" -ne 0 ]
  then echo "Please run with sudo"
  exit
fi

# Update OS
apt-get update
apt-get dist-upgrade -y

# Start reboot at 05:45 every day (give 5 minute warning to anyone logged in)
( crontab -l | grep -v -F "/sbin/shutdown -r +5" || : ; echo "45 5   *   *   *    /sbin/shutdown -r +5" ) | crontab -

# Downlaods and install snapclient
wget https://github.com/badaix/snapcast/releases/download/v0.27.0/snapclient_0.27.0-1_armhf.deb -O /tmp/snapclient.deb
apt-get install -y /tmp/snapclient.deb

# Make filesystem readonly
raspi-config nonint enable_overlayfs

# Reboot
reboot
