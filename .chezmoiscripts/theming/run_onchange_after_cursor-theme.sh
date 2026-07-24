#!/bin/sh
# Customize cursor theme for GTK apps and apps with quirks
#
# With GTK_USE_PORTAL=1 (see dot_config/uwsm/env) the cursor theme comes from `gsettings`,
# so gtk-3.0/settings.ini is ignored, and stored in dconf (the file itself is still left for fallback, in case some apps still try to parse it).
# dconf is a binary blob and can't be tracked by chezmoi directly, hence this script.
#
# GTK property priority:
# gsettings (if `GTK_USE_PORTAL=1` is set), xsettings (X-era daemon), gtk-{3,4}.0/settings.ini, XCURSOR_THEME 
#
# IMPORTANT: Keep in sync with XCURSOR_THEME/XCURSOR_SIZE in dot_config/uwsm/env.
# TODO: find a way to keep them in sync automatically. Maybe a separate theming-related config for all apps?
cursor_theme=breeze_cursors
size=21

# 21 logical px x 1.25 monitor scale = 26 physical.
# Wayland clients get that scaling from the compositor,
# but XWayland is 1:1 under with `xwayland.force_zero_scaling`,
# so X11 clients need the physical value spelled out
# or their cursor comes out too small.
# Exported to the flatpaks that often host X11 clients: Steam, Steam games, and Lutris games.
# NOTE: Steam honours XCURSOR_SIZE but not XCURSOR_THEME (ValveSoftware/steam-for-linux#13209).
xwayland_size=26
xwayland_flatpaks="com.valvesoftware.Steam net.lutris.Lutris"

# gsettings writes via the session bus.
# Without one (e.g. ssh) the write would go nowhere useful, so just skip.
# Unfortunately in this case the script would have to be run again :(
if [ -n "$DBUS_SESSION_BUS_ADDRESS" ]; then
    gsettings set org.gnome.desktop.interface cursor-theme "$cursor_theme"
    gsettings set org.gnome.desktop.interface cursor-size "$size"
else
    echo "theming: no session bus, skipping gsettings" >&2
fi

if command -v flatpak >/dev/null; then
    for app in $xwayland_flatpaks; do
        flatpak override --user --env=XCURSOR_SIZE="$xwayland_size" "$app"
    done
fi
