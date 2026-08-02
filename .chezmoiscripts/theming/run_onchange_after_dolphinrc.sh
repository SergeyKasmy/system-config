#!/bin/sh

# Dolphin writes dolphinrc with instance-specific state, so chezmoi can't own the whole file without fighting it.
# kwriteconfig6 merges just this one key instead, same approach as run_onchange_after_kded-modules.sh.

# ColorScheme=* means "follow the system/global color scheme" instead of a scheme name pinned to this file.
# ...why is this not the default?
kwriteconfig6 --file dolphinrc --group UiSettings --key ColorScheme '*'
