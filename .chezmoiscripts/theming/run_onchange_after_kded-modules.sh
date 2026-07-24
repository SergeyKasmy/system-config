#!/bin/sh
# kded modules to disable.
#
# KDE rewrites kded5rc at runtime, so chezmoi can't own the file without fighting it.
# kwriteconfig6 merges individual keys instead and leaves everything else in the file alone.
# NOTE: KF6's kded reads kded5rc, NOT kded6rc.
#
# * gtkconfig - Regenerates gtk-{3,4}.0/settings.ini, .gtkrc-2.0 and xsettingsd.conf on every login and spawns xsettingsd.
# Let me manage the theme files myself, KDE!
for module in gtkconfig; do
    kwriteconfig6 --file kded5rc --group "Module-$module" --key autoload false
done
