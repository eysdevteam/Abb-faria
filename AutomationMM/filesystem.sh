#!/bin/sh
#Montaje de discos.
sudo mkdir /data
sudo mkdir /log

sudo mkfs -t ext4 /dev/xvdd
sudo mkfs -t ext4 /dev/xvdl

sudo file -s /dev/xvdl
sudo file -s /dev/xvdd

sudo mount /dev/xvdd /data
sudo mount /dev/xvdl /log

sudo cp /etc/fstab /etc/fstab.bk
sudo chmod 777 /etc/fstab
sudo sed -i '9d' /etc/fstab

sudo blkid >> /etc/fstab


sudo sed -i 's|/dev/xvda1: ||g' /etc/fstab
sudo sed -i 's|/dev/xvdd: ||g' /etc/fstab
sudo sed -i 's|/dev/xvdl: ||g' /etc/fstab
sudo sed -i -e 's/TYPE="ext4"/ext4     defaults,nofail 0 2/' /etc/fstab
sudo sed -i -e 's/TYPE="xfs"/xfs       defaults        0 0/' /etc/fstab
sudo sed -i -e 's/="/=/' /etc/fstab
sudo sed -i -e 10's|" e|  /data  e|' /etc/fstab
sudo sed -i -e 11's|" e|  /log  e|' /etc/fstab
sudo sed -i -e 's|" x|   /      x|' /etc/fstab

sudo chmod 644 /etc/fstab

sudo mount -a
