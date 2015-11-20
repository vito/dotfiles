$HOME/.screenlayout/mirrored.sh

xautolock -time 30 -locker "slock" -detectsleep &

INFINALITY=/etc/X11/xinit/xinitrc.d/infinality-settings.sh
if [ -e "$INFINALITY" ]; then
  source "$INFINALITY"
fi

exec xmonad
