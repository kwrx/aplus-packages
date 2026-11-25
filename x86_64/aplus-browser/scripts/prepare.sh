#!/bin/sh
set -e

src=$1
host=$2
aplus=$3
shift 2

sdk=$src/__sdk

rm -rf $sdk
mkdir -p $sdk/usr/include $sdk/usr/lib

for dep in "$@"; do
    for dir in include lib; do
        if [ -d $dep/__out/usr/$dir ]; then
            cp -rsf $dep/__out/usr/$dir/. $sdk/usr/$dir/
        fi
    done
done

find $aplus/lib -name '*.a' -exec ln -sf {} $sdk/usr/lib/ \;
ln -sfn freetype2 $sdk/usr/include/freetype

grep -q "CAIRO_HAS_FC_FONT 1" $sdk/usr/include/cairo/cairo-features.h

toolchain=$(dirname $(dirname $(command -v $host-gcc)))

cmake -G Ninja -S $src -B $src/__build \
    -DPORT=APLUS \
    -DCMAKE_TOOLCHAIN_FILE=$src/Source/cmake/APLUS.cmake \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_POLICY_VERSION_MINIMUM=3.5 \
    -DAPLUS_TOOLCHAIN=$toolchain \
    -DAPLUS_SDK_DIR=$sdk/usr \
    -DCairo_INCLUDE_DIR=$sdk/usr/include/cairo \
    -DCairo_LIBRARY=$sdk/usr/lib/libcairo.a
