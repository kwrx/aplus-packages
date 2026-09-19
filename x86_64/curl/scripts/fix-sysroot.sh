#!/bin/sh
# Fix libtool error when building with --with-sysroot
# libtool: error: `$SYSROOT/usr/lib/libcrypto.la' is not a valid libtool archive
# LibreSSL records the dependency as `=/usr/lib/libcrypto.la' and libtool
# re-roots the `=' into this package sysroot instead of the LibreSSL one.

COMMAND=$1
SYSROOT=$2
LIBRESSL_PREFIX=$3
ZLIB_PREFIX=$4


case $COMMAND in
--init)

    mkdir -p $SYSROOT
    mkdir -p $SYSROOT/usr
    mkdir -p $SYSROOT/usr/lib

    ln -sf $LIBRESSL_PREFIX/lib/libcrypto.la $SYSROOT/usr/lib/libcrypto.la
    ln -sf $LIBRESSL_PREFIX/lib/libcrypto.a $SYSROOT/usr/lib/libcrypto.a
    ln -sf $LIBRESSL_PREFIX/lib/libssl.la $SYSROOT/usr/lib/libssl.la
    ln -sf $LIBRESSL_PREFIX/lib/libssl.a $SYSROOT/usr/lib/libssl.a
    ln -sf $LIBRESSL_PREFIX/lib/libtls.la $SYSROOT/usr/lib/libtls.la
    ln -sf $LIBRESSL_PREFIX/lib/libtls.a $SYSROOT/usr/lib/libtls.a
    ln -sf $ZLIB_PREFIX/lib/libz.a $SYSROOT/usr/lib/libz.a

    ;;

--clean)

    rm -f $SYSROOT/usr/lib/libcrypto.la
    rm -f $SYSROOT/usr/lib/libcrypto.a
    rm -f $SYSROOT/usr/lib/libssl.la
    rm -f $SYSROOT/usr/lib/libssl.a
    rm -f $SYSROOT/usr/lib/libtls.la
    rm -f $SYSROOT/usr/lib/libtls.a
    rm -f $SYSROOT/usr/lib/libz.a

    ;;

*)
    echo "Usage: $0 --init|--clean"
    exit 1
    ;;

esac
