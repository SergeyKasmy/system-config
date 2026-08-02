#!/bin/sh
# Customize the theme for GTK apps and apps with quirks

# IMPORTANT: Keep gtk-theme/icon-theme in sync with gtk-{3,4}.0/settings.ini and .gtkrc-2.0.
# IMPORTANT: Keep cursor theme in sync with XCURSOR_THEME/XCURSOR_SIZE in dot_config/uwsm/env.
# TODO: find a way to keep them in sync automatically. Maybe a separate theming-related config for all apps?
gtk_theme=Flat-Remix-GTK-Blue-Dark
color_scheme=prefer-dark
icon_theme=Papirus-Dark
theme=breeze_cursors
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

## GTK Theme
# With GTK_USE_PORTAL=1 (see dot_config/uwsm/env) the theme comes from the desktop portal's Settings interface,
# which (via xdg-desktop-portal-gtk) reads them out of `gsettings`.
# This means gtk-{3,4}.0/settings.ini are ignored (the files themselves are still left for fallback, in case some apps still try to parse them).
# dconf is a binary blob and can't be tracked by chezmoi directly, hence this script.
#
# GTK property priority:
# gsettings (if `GTK_USE_PORTAL=1` is set), xsettings (X-era daemon), gtk-{3,4}.0/settings.ini, XCURSOR_THEME 

# gsettings writes via the session bus.
# Without one (e.g. ssh) the write would go nowhere useful, so just skip.
# Unfortunately in this case the script would have to be run again :(
if [ -n "$DBUS_SESSION_BUS_ADDRESS" ]; then
    gsettings set org.gnome.desktop.interface gtk-theme "$gtk_theme"
    gsettings set org.gnome.desktop.interface color-scheme "$color_scheme"
    gsettings set org.gnome.desktop.interface icon-theme "$icon_theme"
    gsettings set org.gnome.desktop.interface cursor-theme "$theme"
    gsettings set org.gnome.desktop.interface cursor-size "$size"
else
    echo "theming: no session bus, skipping gsettings" >&2
fi

## Qt Theme
# Config of KDE apps can't be tracked by chezmoi directly.
# They contain too much runtime/instance-specific state, and owning the file would mean a lot of pointless infighting.
# kwriteconfig6 merges just this one key instead.

# ColorScheme=* means "follow the system/global color scheme" instead of a scheme name pinned to this file.
# ...why is this not the default?
kwriteconfig6 --file dolphinrc --group UiSettings --key ColorScheme '*'

# NOTE: KF6's kded reads kded5rc, NOT kded6rc.
# Disable the gtkconfig module. It regenerates gtk-{3,4}.0/settings.ini, .gtkrc-2.0 and xsettingsd.conf on every login,
# thus overwriting our settings (why...) and spawns `xsettingsd` (double why).
# Let me manage the theme files myself, KDE!
kwriteconfig6 --file kded5rc --group "Module-gtkconfig" --key autoload false

## X11 "quirky" apps
if command -v flatpak >/dev/null; then
    for app in $xwayland_flatpaks; do
        flatpak override --user --env=XCURSOR_SIZE="$xwayland_size" "$app"
    done
fi
