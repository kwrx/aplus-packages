#!/bin/bash

PREFIX=$1
HOST=$2
VERSION=$3

pushd $PREFIX/bin
    $HOST-strip *                                                     || exit 1
popd

pushd $PREFIX/libexec/gcc/$HOST/$VERSION
    for i in cc1 cc1plus collect2 lto1 lto-wrapper; do
        if [ -f $i ]; then
            $HOST-strip $i                                            || exit 1
        fi
    done
popd

pushd $PREFIX/include
    find . -maxdepth 1 -mindepth 1 ! -name c++ -exec rm -rf {} +      || exit 1
popd
