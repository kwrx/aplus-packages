#!/bin/bash

SRCDIR=$1
SYSROOT=$2
HOST=$3
VERSION=$4


#
# C Library
#

mkdir -p $SRCDIR/musl

pushd $SRCDIR/musl                                                                                      || exit 1

    wget https://github.com/kwrx/aplus-musl/releases/latest/download/$HOST-musl.tar.xz                  || exit 1
    tar -xf $HOST-musl.tar.xz                                                                           || exit 1

    mkdir -p $SYSROOT/usr
    mkdir -p $SYSROOT/usr/lib
    mkdir -p $SYSROOT/usr/include

    pushd $HOST                                                                                         || exit 1
        cp -rf . $SYSROOT/usr                                                                           || exit 1
    popd

popd



#
# Configure Libstdc++-v3
#

wget -P $SRCDIR https://ftp.gnu.org/gnu/autoconf/autoconf-$VERSION.tar.xz           || exit 1
tar -xf $SRCDIR/autoconf-$VERSION.tar.xz -C $SRCDIR                                 || exit 1

pushd $SRCDIR/autoconf-$VERSION                                                     || exit 1

    mkdir -p build                                                                  || exit 1

    pushd build                                                                     || exit 1

        ../configure --prefix=$SRCDIR/autoconf-$VERSION/sysroot                     || exit 1

        DESTDIR="" make -j$(nproc)
        DESTDIR="" make -j$(nproc) install

    popd

popd

pushd $SRCDIR/libstdc++-v3                                                          || exit 1

    $SRCDIR/autoconf-$VERSION/sysroot/bin/autoconf                                  || exit 1

popd


