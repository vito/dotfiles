#!/bin/sh

set -e -x

hidpix=2560
hidpiy=1440

lowdpix=2560
lowdpiy=1440

scale=2

xrandr \
  --output eDP1 --mode ${hidpix}x${hidpiy} \
  --output  DP1 --mode ${lowdpix}x${lowdpiy} \
    --right-of eDP1 --primary \
    --scale ${scale}x${scale} \
    --panning "$(expr $lowdpix \* $scale)x$(expr $lowdpiy \* $scale)+${hidpix}+0"
