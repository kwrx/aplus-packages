#!/bin/bash

packages="generic"

for p in $packages; do
    for d in $(find $p -maxdepth 1 -mindepth 1 -type d); do
        pushd $d
            echo "Packing $d..."
            tar cJf ../../$(basename $d).tar.xz * .pkg
        popd
    done
done
