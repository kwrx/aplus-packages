#!/bin/bash

echo "### Packing generic packages"

TARGET=${1:-x86_64}
HOST=${2:-$(gcc -dumpmachine)}
TOOLCHAIN_VERSION=${3:-v0.7.1}

packages="generic"

for p in $packages; do
    for d in $(find $p -maxdepth 1 -mindepth 1 -type d); do
        pushd $d
            echo "Packing $d..."
            tar cJf ../../$(basename $d).tar.xz * .pkg
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

python3 ci/pack.py --verbose

echo "## Clean up"
deactivate
rm -rf .venv

