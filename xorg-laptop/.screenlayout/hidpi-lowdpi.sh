#!/bin/sh

set -e -x

hidpix=2560
hidpiy=1440

lowdpix=2560
lowdpiy=1440

scale=2

xrandr \
  --output eDP1 --mode ${hidpix}x${hidpiy} --pos 0x0 --rotate normal \
  --output DP1 --mode ${lowdpix}x${lowdpiy} --right-of eDP1 --rotate normal \
  --scale ${scale}x${scale} --panning "$(expr $lowdpix \* $scale)x$(expr $lowdpiy \* $scale)+${hidpix}+0"
