#!/bin/sh

set -e -x

xrandr --dpi 96
xrdb -merge -I$HOME $(dirname $0)/.Xresources-lowdpi

lowdpix=2560
lowdpiy=1440

xrandr \
  --output VIRTUAL1 --off \
  --output DP1 --mode ${lowdpix}x${lowdpiy} --scale 1x1 --panning "${lowdpix}x${lowdpiy}+0+0" \
  --output DP2 --off \
  --output eDP1 --off \
  --output HDMI1 --off \
  --output HDMI2 --off
