#!/bin/bash

if [ -z "$1" ]
then
    echo "No argument supplied"
    exit;
else
    URBIT_PIER=$1
fi

echo "Watching examples/ for changes"
while true
do
  sleep 1
  cp examples/app/*.hoon $URBIT_PIER/app
done
