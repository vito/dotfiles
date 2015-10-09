xrandr --dpi 192

xrdb -merge -I$HOME ~/.Xresources

# enable tap-to-click
xinput set-prop 11 272 1

exec xmonad
