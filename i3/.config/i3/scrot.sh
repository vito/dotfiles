#!/bin/bash

set -u -x

cd ~/scrots

args=""
case "$1" in
  "selection")
    read selection ok < <(slop -q -c 0.878,0.424,0.459 -b 2 -f '%x,%y,%w,%h ok')
    if [ -z "$ok" ]; then
      exit 1
    fi

    args="-a $selection"

    ;;
esac

f=$(date +'%F@%T.png')

scrot "$f" $args

ln -sf $f latest
xdg-open $f
