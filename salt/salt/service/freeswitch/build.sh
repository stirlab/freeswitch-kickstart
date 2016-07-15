#!/usr/bin/env bash

./bootstrap.sh -j
./configure

make
make install
make sounds-install
make moh-install
# TODO: Is there a way to make testing config?
make samples

