#!/bin/bash

set -u -x

cd ~/scrots

read x y w h ok < <(slop -q -c 0.878,0.424,0.459 -b 2 -f '%x %y %w %h ok')
if [ -z "$ok" ]; then
  exit 1
fi

f=$(date +'%F@%T.gif')

mkfifo /tmp/byzanz
byzanz-record $f -x $x -y $y -w $w -h $h -c -e 'cat /tmp/byzanz'

ln -sf $f latest
xdg-open $f
