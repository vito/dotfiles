$HOME/.screenlayout/mirrored.sh

xautolock -time 30 -locker "slock" -detectsleep &

. /etc/X11/xinit/xinitrc.d/infinality-settings.sh

exec xmonad
