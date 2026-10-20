#!/bin/bash

echo "### Packing generic packages"

TARGET=${1:-x86_64}
HOST=${2:-$(gcc -dumpmachine)}
TOOLCHAIN_VERSION=${3:-0.2.0}

packages="generic"

for p in $packages; do
    for d in $(find $p -maxdepth 1 -mindepth 1 -type d); do
        pushd $d
            echo "Packing $d..."
            tar cJf ../../$(basename $d).tar.xz .pkg *
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
if [ -d /tmp/aplus-packages-build ]; then
    rm -rf /tmp/aplus-packages-build
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


echo "### Run build-system"

if ! python3 ci/pack.py --verbose; then

    echo "### Build failed, dumping logs"

    for f in /tmp/aplus-packages-build/*/__build/*.err; do
        if [ -s $f ]; then
            echo "::group::$f"
            cat $f
            echo "::endgroup::"
        fi
    done

    last=$(ls -t /tmp/aplus-packages-build/*/__build/*.log 2> /dev/null | head -n 1)

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

echo "## Clean up"
deactivate
rm -rf .venv
rm -rf sdk
rm -rf /tmp/aplus-packages-build
