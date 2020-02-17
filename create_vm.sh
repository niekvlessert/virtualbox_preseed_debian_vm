#!/bin/bash

if [ -z "$3" ]; then
	echo "Usage $0 <vm_name> <user> <user & root password>"
	exit
fi

VM=$1
USER=$2
PASS=$3
rm -rf 1
mkdir 1
aux_base_path=`pwd`/1/$VM-

#VBoxManage list ostypes
VBoxManage createvm --name $VM --ostype "Debian_64" --register

VBoxManage createhd --filename /Volumes/SSD/Virtualbox/$VM/$VM.vdi --size 32768
VBoxManage storagectl $VM --name "SATA Controller" --add sata --controller IntelAHCI
VBoxManage storageattach $VM --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium /Volumes/SSD/Virtualbox/$VM/$VM.vdi
VBoxManage storagectl $VM --name "IDE Controller" --add ide
VBoxManage storageattach $VM --storagectl "IDE Controller" --port 0 --device 0 --type dvddrive --medium /Volumes/SSD/iso/debian-10.2.0-amd64-netinst.iso

VBoxManage modifyvm $VM --memory 2048 --vram 128 --nic1 bridged --bridgeadapter1 'en1: Wi-Fi (AirPort)' --graphicscontroller vmsvga
timezone=$(date +%Z)
VBoxManage unattended install $VM --auxiliary-base-path $aux_base_path --iso=/Volumes/SSD/iso/debian-10.2.0-amd64-netinst.iso --user=$USER --full-user-name=$USER --password $PASS --install-additions --time-zone=$timezone

patch ${aux_base_path}isolinux-txt.cfg < fix.patch
sed -i '' $'s/# Grub/tasksel tasksel\/first multiselect standard, ssh-server\\\nd-i pkgsel\/include string git mlocate vim ntp\\\n# Grub/g' ${aux_base_path}preseed.cfg

VBoxManage startvm $VM
