#!/bin/sh
set -e

src=$1
host=$2
cairorecipe=$3
cairosrc=$4
aplus=$5
shift 4

sdk=$src/__sdk
cairo=$src/__cairo

rm -rf $sdk $cairo
mkdir -p $sdk/usr/include $sdk/usr/lib $cairo

for dep in "$@"; do
    for dir in include lib; do
        if [ -d $dep/__out/usr/$dir ]; then
            cp -rsf $dep/__out/usr/$dir/. $sdk/usr/$dir/
        fi
    done
done

find $aplus/lib -name '*.a' -exec ln -sf {} $sdk/usr/lib/ \;
ln -sfn freetype2 $sdk/usr/include/freetype
ln -sf libfreetype.a $sdk/usr/lib/libfreetype2.a

(cd $cairosrc && tar cf - --exclude=./__build --exclude=./__out .) | (cd $cairo && tar xf -)

cd $cairo
PKG_CONFIG=/usr/bin/pkg-config \
PKG_CONFIG_LIBDIR=$sdk/usr/lib/pkgconfig \
PKG_CONFIG_SYSROOT_DIR=$sdk \
CFLAGS="-O2 -march=x86-64 -mtune=generic -I$sdk/usr/include -I$sdk/usr/include/freetype2 -I$sdk/usr/include/pixman-1 -I$sdk/usr/include/libpng16" \
LDFLAGS="-L$sdk/usr/lib" \
meson setup __build --cross-file=$cairorecipe/meson/meson-cross-$host.txt \
    -Dprefix=/usr -Dlibdir=lib -Dbuildtype=release -Ddefault_library=static -Dstrip=true -Dwarning_level=1 -Dwerror=false \
    -Ddwrite=disabled -Dfontconfig=enabled -Dfreetype=enabled -Dpng=enabled -Dquartz=disabled -Dtee=disabled \
    -Dxcb=disabled -Dxlib=disabled -Dxlib-xcb=disabled -Dzlib=disabled -Dtests=disabled -Dlzo=disabled \
    -Dgtk2-utils=disabled -Dglib=disabled -Dspectre=disabled -Dsymbol-lookup=disabled
ninja -C __build -j4
DESTDIR=$cairo/__out ninja -C __build install
cp -r --remove-destination $cairo/__out/usr/. $sdk/usr/

grep -q "CAIRO_HAS_FC_FONT 1" $sdk/usr/include/cairo/cairo-features.h

toolchain=$(dirname $(dirname $(command -v $host-gcc)))

cmake -G Ninja -S $src -B $src/__build \
    -DPORT=APLUS \
    -DCMAKE_TOOLCHAIN_FILE=$src/Source/cmake/APLUS.cmake \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_SYSTEM_PROCESSOR=x86_64 \
    -DCMAKE_POLICY_VERSION_MINIMUM=3.5 \
    -DCMAKE_C_COMPILER=$host-gcc \
    -DCMAKE_CXX_COMPILER=$host-g++ \
    -DCMAKE_AR=$(command -v $host-ar) \
    -DCMAKE_RANLIB=$(command -v $host-ranlib) \
    -DCMAKE_NM=$(command -v $host-nm) \
    -DCMAKE_STRIP=$(command -v $host-strip) \
    "-DCMAKE_C_FLAGS=-D_GNU_SOURCE -include $toolchain/$host/include/limits.h" \
    "-DCMAKE_CXX_FLAGS=-D_GNU_SOURCE -include $toolchain/$host/include/limits.h -DU_SHOW_CPLUSPLUS_HEADER_API=0" \
    -DAPLUS_SDK_DIR=$sdk/usr \
    -DCAIRO_INCLUDE_DIRS=$sdk/usr/include/cairo/ \
    -DFREETYPE_INCLUDE_DIRS=$sdk/usr/include/freetype2/ \
    -DLIBXML2_INCLUDE_DIR=$sdk/usr/include/libxml2/ \
    -DZLIB_LIBRARIES=$sdk/usr/lib/libz.a
