# load base Xresources
xrdb -merge -I$HOME ~/.Xresources

# enable tap-to-click
xinput set-prop 11 272 1

# auto-lock after 10 minutes
if which slock >/dev/null; then
  xautolock -time 10 -locker slock &
fi

# start window manager
exec xmonad
