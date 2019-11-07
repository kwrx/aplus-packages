#!/bin/bash

for d in $(find $1 -maxdepth 1 -mindepth 1 -type d); do
    pushd $d
        echo "Packing $d..."
        tar cjf ../../$(basename $d).tar.xz .
    popd
done