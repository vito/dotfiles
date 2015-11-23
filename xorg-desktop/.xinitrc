# set up infinality
INFINALITY=/etc/X11/xinit/xinitrc.d/infinality-settings.sh
if [ -e "$INFINALITY" ]; then
  source "$INFINALITY"
fi

# load base Xresources
xrdb -merge -I$HOME ~/.Xresources

# configure mirrored displays
$HOME/.screenlayout/mirrored.sh

# auto-lock after 30 minutes
if which slock >/dev/null; then
  xautolock -time 30 -locker slock -detectsleep &
fi

# start window manager
exec xmonad
