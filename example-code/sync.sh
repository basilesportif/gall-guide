#!/bin/bash
if [ -z "$1" ]
then
    echo "usage: sync.sh URBIT_PIER_DIRECTORY"
    exit;
fi

cp -r gen/* $1/gen
cp -r app/* $1/app/
cp -r lib/* $1/lib/
cp -r mar/* $1/mar/
cp -r sur/* $1/sur/


