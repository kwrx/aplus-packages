#!/bin/sh

if [ -d $1/etc ]; then
    rm -rf $1/etc
fi

mv $1/usr/etc $1/etc