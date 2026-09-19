#!/bin/sh

if [ -d $1/__out ]; then
    rmdir $1/__out
fi

ln -sf $1/root $1/__out