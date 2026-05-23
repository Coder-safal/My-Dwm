#!/bin/sh

# Environment variables
export GDK_BACKEND=x11
export NO_AT_BRIDGE=1
export QT_QPA_PLATFORM=xcb
export QT_QPA_PLATFORMTHEME=gtk2
export XDG_RUNTIME_DIR="/run/user/$(id -u)"
export XDG_SESSION_TYPE=x11

# System resources
SYS_RESOURCES=/etc/X11/xinit/.Xresources
SYS_MODMAP=/etc/X11/xinit/.Xmodmap

[ -f "$SYS_RESOURCES" ] && xrdb -merge "$SYS_RESOURCES"
[ -f "$SYS_MODMAP" ] && xmodmap "$SYS_MODMAP"

[ -f /etc/xprofile ] && . /etc/xprofile
[ -f "$HOME/.xprofile" ] && . "$HOME/.xprofile"
[ -f "$HOME/.profile" ] && . "$HOME/.profile"
[ -f "$HOME/.Xresources" ] && xrdb -merge -I "$HOME" "$HOME/.Xresources"

# Start dwm
exec dwm
