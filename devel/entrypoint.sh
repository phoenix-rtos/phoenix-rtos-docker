#!/bin/bash
sudo service dbus start
sudo service dnsmasq start
sudo libvirtd -d
sudo virsh net-start --network Qemu_bridge

sudo mkdir /etc/qemu
sudo chmod a+rw /etc/qemu
sudo echo "allow virbr0" > /etc/qemu/bridge.conf
sudo chmod a+rw /etc/qemu/bridge.conf

# exec /bin/bash
./phoenix-rtos-tests/runner.py "$@"
