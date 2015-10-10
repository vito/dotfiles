#!/bin/sh

set -e -x

hidpix=2560
hidpiy=1440

xrandr \
  --output eDP1 --mode ${hidpix}x${hidpiy} \
  --output  DP1 --off
