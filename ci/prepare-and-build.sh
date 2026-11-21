#!/bin/bash

echo "### Packing generic packages"

TARGET=${1:-x86_64}
HOST=${2:-$(gcc -dumpmachine)}
TOOLCHAIN_VERSION=${3:-0.2.0}
ZIG_VERSION=${4:-0.17.1}

packages="generic"
BUILD_DIR=$(pwd)/build

for p in $packages; do
    for d in $(find $p -maxdepth 1 -mindepth 1 -type d); do
        pushd $d
            echo "Packing $d..."
            tar cJf ../../$(basename $d).tar.xz --owner=0 --group=0 --numeric-owner .pkg *
        popd
    done
done


echo "### Install dependencies"

python3 -m venv .venv
source .venv/bin/activate

python -m pip install --upgrade pip
python -m pip install --upgrade setuptools
python -m pip install --upgrade wheel
python -m pip install --upgrade twine
python -m pip install -r requirements.txt


if [ -d sdk ]; then
    rm -rf sdk
fi
if [ -d $BUILD_DIR ]; then
    rm -rf $BUILD_DIR
fi

echo "### Install toolchain"
mkdir -p sdk

pushd sdk
    if [ ! -f $TARGET-aplus-toolchain-$HOST.tar.xz ]; then
        wget https://github.com/kwrx/aplus-toolchain/releases/download/$TOOLCHAIN_VERSION/$TARGET-aplus-toolchain-$HOST.tar.xz || exit 1
    fi
    tar xJf $TARGET-aplus-toolchain-$HOST.tar.xz || exit 1
popd

export PATH=$(pwd)/sdk/bin:$PATH


echo "### Install zig"
mkdir -p sdk/zig

pushd sdk
    ZIG_ARCHIVE=zig-$(uname -m)-linux-$ZIG_VERSION.tar.xz

    if [ ! -f $ZIG_ARCHIVE ]; then
        wget https://ziglang.org/download/$ZIG_VERSION/$ZIG_ARCHIVE || exit 1
    fi
    tar xJf $ZIG_ARCHIVE -C zig --strip-components=1 || exit 1
popd

export ZIG=$(pwd)/sdk/zig/zig
$ZIG version || exit 1


echo "### Run build-system"

if [ -z "${APLUS_PREBUILT_URL+x}" ] && [ -n "$GITHUB_REPOSITORY" ]; then
    APLUS_PREBUILT_URL=https://github.com/$GITHUB_REPOSITORY/releases/latest/download
fi

BUILD_SALT="$TARGET:$TOOLCHAIN_VERSION:$ZIG_VERSION:$(sha256sum requirements.txt | cut -d' ' -f1):${APLUS_CACHE_SALT:-}"

if ! python3 ci/pack.py --verbose --tmpdir "$BUILD_DIR" --prebuilt "${APLUS_PREBUILT_URL:-}" --salt "$BUILD_SALT"; then

    echo "### Build failed, dumping logs"

    for f in $BUILD_DIR/*/__build/*.err; do
        if [ -s $f ]; then
            echo "::group::$f"
            cat $f
            echo "::endgroup::"
        fi
    done

    last=$(ls -t $BUILD_DIR/*/__build/*.log 2> /dev/null | head -n 1)

    if [ -n "$last" ]; then
        echo "### Failed step: ${last%.log}"
        echo "--- ${last}"
        tail -n 200 $last
        echo "--- ${last%.log}.err"
        tail -n 200 ${last%.log}.err
    fi

    if [ -f $(dirname "$last")/meson-logs/meson-log.txt ]; then
        echo "--- $(dirname $last)/meson-logs/meson-log.txt"
        tail -n 100 $(dirname $last)/meson-logs/meson-log.txt
    fi

    exit 1
fi

echo "### Index generic packages"

for p in $packages; do
    for d in $(find $p -maxdepth 1 -mindepth 1 -type d -name 'system-*'); do
        name=$(basename $d)
        version=$(tr -d '[:space:]' < $d/.pkg/version)
        sha256=$(sha256sum $name.tar.xz | cut -d' ' -f1)
        echo "$name:$version:$sha256:" >> index
    done
done

echo "## Clean up"
deactivate
rm -rf .venv
rm -rf sdk
rm -rf $BUILD_DIR
