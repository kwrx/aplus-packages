#!/bin/bash

echo "### Packing generic packages"

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

python3 -m pip install --user --upgrade pip
python3 -m pip install --user --upgrade setuptools
python3 -m pip install --user --upgrade wheel
python3 -m pip install --user --upgrade twine
python3 -m pip install -r requirements.txt



echo "### Install toolchain"

mkdir -p sdk

pushd sdk
wget https://github.com/kwrx/aplus-toolchain/releases/latest/download/x86_64-aplus-toolchain.tar.xz
tar xJf x86_64-aplus-toolchain.tar.xz
popd

export PATH=$(pwd)/sdk/bin:$PATH


echo "### Run build-system"

python3 ci/pack.py --clean

