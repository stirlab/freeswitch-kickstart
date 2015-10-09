#!/bin/bash

# Handles all details of setting up the development virtual server.

VAGRANT_CONFIG_DIR=$1
VM_INSTALL_DIR="${HOME}/vagrant/freeswitch-dev"
FREESWITCH_GIT_DIR="${HOME}/git/freeswitch"
SALT_DIR="`dirname $VAGRANT_CONFIG_DIR 2> /dev/null`/salt"
VAGRANT_VM_BOX="bento/debian-8.2"
SALT_MINION_ID="dev.freeswitch.local"
ALLOW_VM_FILE_SYNC_TIME="yes"
SSH_PORT="2222"
AUTOMATICALLY_MANAGE_HOST_ENTRIES="yes"

SCRIPT_NAME=`basename $0`

usage() {
echo "
This script initializes a fully functional development server on a
Vagrant virtual machine.

Usage: $SCRIPT_NAME <vagrant_config_dir> [dev_user] [dev_server]

  vagrant_config_dir: The directory containing the Vagrantfile to use.
  dev_user: The user name of the user on the main development server.
  dev_server: The SSH config name of the main development server.

dev_user and dev_server are optional, if provided they will be used to download
the Salt configuration. Otherwise, the Salt configuration will installed from
[vagrant_config_dir]/salt if it is found there.
"
}

if [ "$1" = "help" ]; then
  usage
  exit 1
fi

if [ $# -lt 1 ]; then
  usage
  exit 1
fi

if [ -f ${VAGRANT_CONFIG_DIR}/settings.sh ]; then
  . ${VAGRANT_CONFIG_DIR}/settings.sh
fi

echo "Creating ${VM_INSTALL_DIR}..."
mkdir -p ${VM_INSTALL_DIR}

echo "Setting up Vagrant configuration for server..."
cd $VM_INSTALL_DIR
cp ${VAGRANT_CONFIG_DIR}/Vagrantfile .
# Cross-platform trick for sed inline editing.
sed -i.bak "s%###SSH_PORT###%${SSH_PORT}%g" Vagrantfile
rm Vagrantfile.bak
sed -i.bak "s%###VAGRANT_VM_BOX###%${VAGRANT_VM_BOX}%g" Vagrantfile
rm Vagrantfile.bak
sed -i.bak "s%###SALT_DIR###%${SALT_DIR}%g" Vagrantfile
rm Vagrantfile.bak
sed -i.bak "s%###SALT_MINION_ID###%${SALT_MINION_ID}%g" Vagrantfile
rm Vagrantfile.bak
if [ -n "${FREESWITCH_GIT_DIR}" ]; then
  sed -i.bak "s%###FREESWITCH_GIT_DIR###%${FREESWITCH_GIT_DIR}%g" Vagrantfile
  rm Vagrantfile.bak
fi

echo "Copying salt config from ${VAGRANT_CONFIG_DIR}/salt..."
rsync -avz --progress ${VAGRANT_CONFIG_DIR}/salt .

sed -i.bak "s%###SALT_MINION_ID###%${SALT_MINION_ID}%g" salt/minion
rm salt/minion.bak

echo "Booting server..."
vagrant up --no-provision

# This is necessary so that the vagrant-vbguest plugin can be properly
echo "Ensuring gcc/make/kernel-devel are installed..."
vagrant ssh -- "sudo apt-get -q -y install gcc make linux-kernel-headers linux-headers-\$(uname -r)"
echo "Installing some useful preliminary packages"
vagrant ssh -- "sudo apt-get -q -y install rsync vim"

vagrant plugin install vagrant-vbguest
if [ "$AUTOMATICALLY_MANAGE_HOST_ENTRIES" = "yes" ]; then
  vagrant plugin install vagrant-hostsupdater
fi

echo "Activating vagrant-vbguest plugin..."
sed -i.bak "s/config\.vbguest\.auto_update = false$/config.vbguest.auto_update = true/" Vagrantfile
rm Vagrantfile.bak

# Reloading here allows the vagrant-vbguest plugin to handle its job before
# the rest of the install.
echo "Provisioning server..."
vagrant reload --provision

if [ "$ALLOW_VM_FILE_SYNC_TIME" = "yes" ]; then
  # There is sometimes a slight delay in syncing files from the VM to a shared
  # host directory, allow time for it.
  echo "Waiting for files to sync to host..."
  sleep 60
fi

# Final reboot takes care of making sure all services come up on boot, etc.
echo "Rebooting server..."
vagrant reload

