#!/bin/bash

PREFIX=$1
HOST=$2
VERSION=$3

pushd $PREFIX/bin
    $HOST-strip *                                                     || exit 1
popd

pushd $PREFIX/libexec/gcc/$HOST/$VERSION
    $HOST-strip cc1 cc1plus collect2 lto1 lto-wrapper                 || exit 1
popd

pushd $PREFIX/include
    rm -rf *
popd