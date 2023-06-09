#!/bin/bash

# sudo check
if [ "$EUID" -ne 0 ]
  then echo "Please run with sudo"
  exit
fi

# Enable Hifiberry Overlay
# TODO identify hifiberry amp and set correct overlay (hifiberry-amp)
sed -i "/^dtparam=audio=on/c #dtparam=audio=on\ndtoverlay=hifiberry-dac" /boot/config.txt

# Update OS
apt-get update
apt-get dist-upgrade -y

# Start reboot at 05:45 every day (give 5 minute warning to anyone logged in)
( crontab -l | grep -v -F "/sbin/shutdown -r +5" || : ; echo "45 5   *   *   *    /sbin/shutdown -r +5" ) | crontab -

# Download and install snapclient
wget https://github.com/badaix/snapcast/releases/download/v0.27.0/snapclient_0.27.0-1_armhf.deb -O /tmp/snapclient.deb
apt-get install -y /tmp/snapclient.deb

# Power Optimisations
# Disable HDMI
sudo /opt/vc/bin/tvservice -o
# Disable BT and WiFi
grep -qxF 'dtoverlay=disable-bt' /boot/config.txt || echo 'dtoverlay=disable-bt' >> /boot/config.txt
grep -qxF 'dtoverlay=disable-wifi' /boot/config.txt || echo 'dtoverlay=disable-wifi' >> /boot/config.txt
# Pi specific savings
case `raspi-config nonint get_pi_type` in

  0)
    # Pi Zero
    # Turn off LED
    grep -qxF 'dtparam=pwr_led_trigger=default-on' /boot/config.txt || echo 'dtparam=pwr_led_trigger=default-on' >> /boot/config.txt
    grep -qxF 'dtparam=pwr_led_activelow=off' /boot/config.txt || echo 'dtparam=pwr_led_activelow=off' >> /boot/config.txt
    ;;

  1)
    echo 'one'
    ;;

  2)
    echo ''
    ;;

  3)
    # Pi 3
    # Turn off Power LED
    grep -qxF 'dtparam=pwr_led_trigger=none' /boot/config.txt || echo 'dtparam=pwr_led_trigger=none' >> /boot/config.txt
    grep -qxF 'dtparam=pwr_led_activelow=off' /boot/config.txt || echo 'dtparam=pwr_led_activelow=off' >> /boot/config.txt
    # Turn off Activity LED
    grep -qxF 'dtparam=act_led_trigger=none' /boot/config.txt || echo 'dtparam=act_led_trigger=none' >> /boot/config.txt
    grep -qxF 'dtparam=act_led_activelow=off' /boot/config.txt || echo 'dtparam=act_led_activelow=off' >> /boot/config.txt
    # Turn off Ethernet ACT LED
    grep -qxF 'dtparam=eth_led0=14' /boot/config.txt || echo 'dtparam=eth_led0=14' >> /boot/config.txt
    # Turn off Ethernet LNK LED
    grep -qxF 'dtparam=eth_led1=14' /boot/config.txt || echo 'dtparam=eth_led1=14' >> /boot/config.txt
    ;;
  
  4)
    # Pi 4
    # Turn off Power LED
    grep -qxF 'dtparam=pwr_led_trigger=default-on' /boot/config.txt || echo 'dtparam=pwr_led_trigger=default-on' >> /boot/config.txt
    grep -qxF 'dtparam=pwr_led_activelow=off' /boot/config.txt || echo 'dtparam=pwr_led_activelow=off' >> /boot/config.txt
    # Turn off Activity LED
    grep -qxF 'dtparam=act_led_trigger=none' /boot/config.txt || echo 'dtparam=act_led_trigger=none' >> /boot/config.txt
    grep -qxF 'dtparam=act_led_activelow=off' /boot/config.txt || echo 'dtparam=act_led_activelow=off' >> /boot/config.txt
    # Turn off Ethernet ACT LED
    grep -qxF 'dtparam=eth_led0=4' /boot/config.txt || echo 'dtparam=eth_led0=4' >> /boot/config.txt
    # Turn off Ethernet LNK LED
    grep -qxF 'dtparam=eth_led1=4' /boot/config.txt || echo 'dtparam=eth_led1=4' >> /boot/config.txt
    ;;
esac

# Make filesystem readonly
raspi-config nonint enable_overlayfs
# Make /boot read only
raspi-config nonint enable_bootro

# Reboot
reboot
