#!/bin/sh

if pip3 freeze | grep meson; then
    echo "meson is already installed"
else
    echo "Installing meson"
    pip3 install meson
fi