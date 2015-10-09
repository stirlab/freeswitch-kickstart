#!/bin/bash

./bootstrap.sh -j
./configure -C

# Modify modules.conf to add some video deps.
/usr/bin/perl  -i -pe 's/#applications\/mod_av/applications\/mod_av/g' modules.conf
/usr/bin/perl  -i -pe 's/#formats\/mod_vlc/formats\/mod_vlc/g' modules.conf

# TODO: Remove this?
# This was broken for me on build, and it shouldn't impact the video testing.
#/usr/bin/perl  -i -pe 's/applications\/mod_spandsp/#applications\/mod_spandsp/g' modules.conf

make
make install
make sounds-install
make moh-install
# TODO: Is there a way to make testing config?
make samples

