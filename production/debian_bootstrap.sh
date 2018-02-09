#!/usr/bin/env sh

# Bootstraps the repository and installs Salt.

PROJECT_NAME="freeswitch-kickstart"
SALT_GIT_TAG="v2017.7.3"

HOSTNAME=`hostname`

apt-get update
apt-get -y install git
mkdir -p /var/local/git
cd /var/local/git && git clone https://github.com/thehunmonkgroup/${PROJECT_NAME}.git
ln -s /var/local/git/${PROJECT_NAME}/salt /srv/salt
cd && wget -O install_salt.sh https://bootstrap.saltstack.com && sh install_salt.sh -X -d git ${SALT_GIT_TAG} && systemctl disable salt-minion.service && systemctl stop salt-minion.service
rm install_salt.sh
cp /var/local/git/${PROJECT_NAME}/production/salt/minion /etc/salt/
sed -i.bak "s%###SALT_MINION_ID###%${HOSTNAME}%g" /etc/salt/minion
rm /etc/salt/minion.bak
mkdir -p /etc/salt/minion.d
cp /var/local/git/${PROJECT_NAME}/production/salt/grains.conf /etc/salt/minion.d/

echo "
If you see no error messages, the bootstrap was successful. Follow the
instructions in INSTALL.md for configuring pillar data and SSL certs, then
run the following command to complete the installation:

  salt-call state.highstate
"
