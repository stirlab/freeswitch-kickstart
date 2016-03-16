#!/bin/bash

./bootstrap.sh -j
./configure

# Modify modules.conf to add some video deps.
/usr/bin/perl  -i -pe 's/#applications\/mod_av/applications\/mod_av/g' modules.conf
/usr/bin/perl  -i -pe 's/#formats\/mod_vlc/formats\/mod_vlc/g' modules.conf

make
make install
make sounds-install
make moh-install
# TODO: Is there a way to make testing config?
make samples

