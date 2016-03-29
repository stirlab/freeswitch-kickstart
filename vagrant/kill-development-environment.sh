#!/bin/bash

# Removes all files associated with the development environment, use with
# extreme caution!

VM_INSTALL_DIR="${HOME}/vagrant/freeswitch-kickstart"
FREESWITCH_GIT_DIR="${HOME}/git/freeswitch"

SCRIPT_NAME=`basename $0`

usage() {
echo "
This script handles all necessary host-level tasks necessary for
completely removing a local development installation via Vagrant.

Usage: $SCRIPT_NAME
"
}

if [ "$1" = "help" ]; then
  usage
  exit 1
fi

if [ $# -ne 0 ]; then
  usage
  exit 1
fi

find_full_path_to_file() {
  local CWD=`pwd`
  local DIR=`dirname $0`
  local FULL_PATH=`echo "$(cd "$DIR"; pwd)"`
  cd $CWD
  echo "$FULL_PATH"
}

VAGRANT_CONFIG_DIR=`find_full_path_to_file`

if [ -f ${VAGRANT_CONFIG_DIR}/settings.sh ]; then
  . ${VAGRANT_CONFIG_DIR}/settings.sh
fi

CWD=`pwd`

if [ -d $VM_INSTALL_DIR ]; then
  echo -n "Are you sure you want to remove all of ${VM_INSTALL_DIR}? (y/N): "
  read KILL_VM

  if [ "$KILL_VM" = "y" ]; then
    echo "Removing $VM_INSTALL_DIR development virtual machine"
    cd $VM_INSTALL_DIR
    vagrant halt
    vagrant destroy -f
    cd $CWD
    rm -rf $VM_INSTALL_DIR

    echo "Removal complete."

    if [ -n "$FREESWITCH_GIT_DIR" ] && [ -d "$FREESWITCH_GIT_DIR" ]; then
      echo "$FREESWITCH_GIT_DIR was preserved, and can be removed manually."
    fi

  else
    echo "User cancelled"
  fi
else
  echo "$VM_INSTALL_DIR does not exist, skipping."
fi

