# load base Xresources
xrdb -merge -I$HOME ~/.Xresources

# enable tap-to-click
xinput set-prop 11 272 1

# start window manager
exec xmonad
