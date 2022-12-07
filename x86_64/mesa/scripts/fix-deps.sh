#!/bin/sh

if which meson > /dev/null; then
    echo "checking for meson: $(which meson)"
else
    echo "checking for meson: not found, installing meson"
    pip3 install --user meson
fi