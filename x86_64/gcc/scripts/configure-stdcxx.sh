#!/bin/bash

SRCDIR=$1
SYSROOT=$2
HOST=$3
VERSION=$4


#
# C Library
#

rm -rf $SRCDIR/musl                                                                                     || exit 1
git clone --depth 1 https://github.com/kwrx/aplus-musl $SRCDIR/musl                                     || exit 1

mkdir -p $SRCDIR/musl/build

pushd $SRCDIR/musl/build                                                                                || exit 1

    ../configure --prefix=/usr --host=$HOST --disable-shared --enable-static                            || exit 1

    make -j$(nproc)                                                                                     || exit 1
    make -j$(nproc) DESTDIR=$SYSROOT install                                                            || exit 1

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


