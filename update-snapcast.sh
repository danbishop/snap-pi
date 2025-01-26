#!/bin/bash
USERNAME=dan
HOSTS="bathroom hallway livingroom diningroom kitchen garden"

# Disable overlay filesystem on each pi
for HOSTNAME in ${HOSTS} ; do
    echo "Disabling overlay filesystem on ${HOSTNAME}"
    ssh -l ${USERNAME} ${HOSTNAME} "sudo raspi-config nonint do_overlayfs 1; sudo reboot"
done

sleep 120

# Update OS
for HOSTNAME in ${HOSTS} ; do
    echo "Updating OS on ${HOSTNAME}"
    ssh -l ${USERNAME} ${HOSTNAME} "export DEBIAN_FRONTEND=noninteractive; sudo apt-get update; sudo apt-get -y dist-upgrade"
done

# Update snapcast
for HOSTNAME in ${HOSTS} ; do
    echo "Updating snapcast on ${HOSTNAME}"
    ssh -l ${USERNAME} ${HOSTNAME} 'source /etc/os-release; wget -O /tmp/snapclient.deb https://github.com/badaix/snapcast/releases/download/v0.31.0/snapclient_0.31.0-1_armhf_$VERSION_CODENAME.deb; sudo apt-get install /tmp/snapclient.deb'
done

# Re-enable overlay filesystem on each pi
for HOSTNAME in ${HOSTS} ; do
    echo "Re-enabling overlay filesystem on ${HOSTNAME}"
    ssh -l ${USERNAME} ${HOSTNAME} "sudo raspi-config nonint do_overlayfs 0; sudo reboot"
done
