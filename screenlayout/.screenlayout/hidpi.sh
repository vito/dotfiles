#!/bin/sh

set -e -x

xrandr --dpi 192
xrdb -merge -I$HOME $(dirname $0)/.Xresources-hidpi

hidpix=2560
hidpiy=1440

xrandr \
  --output VIRTUAL1 --off \
  --output DP1 --off \
  --output DP2 --off \
  --output eDP1 --mode ${hidpix}x${hidpiy} \
  --output HDMI1 --off \
  --output HDMI2 --off
