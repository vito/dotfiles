#!/bin/sh
xrandr --output VIRTUAL1 --off --output eDP1 --mode 2560x1440 --pos 0x0 --rotate normal --output DP1 --off --output HDMI2 --mode 2560x1440 --pos 0x0 --rotate normal --output HDMI1 --off --output DP2 --off

#!/bin/sh

set -e -x

hidpix=2560
hidpiy=1440

lowdpix=2560
lowdpiy=1440

scale=2

xrandr \
  --output VIRTUAL1 --off \
  --output DP1 --off \
  --output DP2 --off \
  --output eDP1 --mode ${hidpix}x${hidpiy} \
  --output HDMI1 --off \
  --output HDMI2 --mode ${lowdpix}x${lowdpiy} \
    --right-of eDP1 --primary \
    --scale ${scale}x${scale} \
    --panning "$(expr $lowdpix \* $scale)x$(expr $lowdpiy \* $scale)+${hidpix}+0"
