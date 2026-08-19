#!/bin/bash
USERNAME=dan
HOSTS="bathroom hallway livingroom diningroom kitchen"

# Disable overlay filesystem on each pi
for HOSTNAME in ${HOSTS} ; do
    echo "Disabling overlay filesystem on ${HOSTNAME}"
    ssh -l ${USERNAME} ${HOSTNAME} "sudo raspi-config nonint do_overlayfs 1; raspi-config nonint disable_bootro; sudo reboot"
done

sleep 120

# Update OS
for HOSTNAME in ${HOSTS} ; do
    echo "Updating OS on ${HOSTNAME}"
    ssh -l ${USERNAME} ${HOSTNAME} "export DEBIAN_FRONTEND=noninteractive; sudo apt-get update; sudo apt-get -y dist-upgrade"
done

# Update snapcast
for HOSTNAME in ${HOSTS} ; do
    echo "Updating sendspin on ${HOSTNAME}"
    ssh -l ${USERNAME} ${HOSTNAME} 'curl -fsSL https://raw.githubusercontent.com/LeoLTM/sendspin-armv6/main/scripts/upgrade.sh | sudo bash'
done

# Re-enable overlay filesystem on each pi
for HOSTNAME in ${HOSTS} ; do
    echo "Re-enabling overlay filesystem on ${HOSTNAME}"
    ssh -l ${USERNAME} ${HOSTNAME} "sudo raspi-config nonint do_overlayfs 0; raspi-config nonint enable_bootro; sudo reboot"
done
