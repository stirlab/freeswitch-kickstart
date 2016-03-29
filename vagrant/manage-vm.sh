#!/bin/bash

# Convenience script for starting/stopping the virtual machine.

VM_INSTALL_DIR="${HOME}/vagrant/freeswitch-kickstart"

SCRIPT_NAME=`basename $0`

usage() {
echo "
This script smooths out the little inconsistencies in starting/stopping
a virtual server.

Usage: $SCRIPT_NAME <start|stop|restart|status>

  start: Ensures the VM is started.
  stop: Halts the running instance of the VM.
  restart: Restarts the VM.
  status: Displays the current status of the VM.
"
}

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

start() {
  vagrant up
  RETVAL=$?
}

stop() {
  vagrant halt
  RETVAL=$?
}

restart() {
  stop && start
  RETVAL=$?
}

status() {
  VM_STATUS=`vagrant status`
  RETVAL=$?
  echo "$VM_STATUS" | head -n 4
}

RETVAL=0

CWD=`pwd`
cd $VM_INSTALL_DIR

case "$1" in
  start)
    start
    ;;
  stop)
    stop
    ;;
  restart)
    restart
    ;;
  status)
    status
    ;;
  *)
    usage
    RETVAL=1
esac

cd $CWD

exit $RETVAL

