#!/bin/sh
# Fix libtool error when building with --with-sysroot
# libtool: link: cannot find the library `$SYSROOT/usr/lib/libgmp.la'
# libtool: link: cannot find the library `$SYSROOT/usr/lib/libmpfr.la'

COMMAND=$1
SYSROOT=$2
GMP_PREFIX=$3
MPFR_PREFIX=$4


case $COMMAND in
--init)

    mkdir -p $SYSROOT
    mkdir -p $SYSROOT/usr
    mkdir -p $SYSROOT/usr/lib

    ln -sf $GMP_PREFIX/lib/libgmp.la $SYSROOT/usr/lib/libgmp.la
    ln -sf $MPFR_PREFIX/lib/libmpfr.la $SYSROOT/usr/lib/libmpfr.la

    ;;

--clean)

    rm -f $SYSROOT/usr/lib/libgmp.la
    rm -f $SYSROOT/usr/lib/libmpfr.la

    ;;

*)
    echo "Usage: $0 --init|--clean"
    exit 1
    ;;

esac
