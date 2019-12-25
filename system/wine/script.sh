#!/bin/sh

# Set default wine prefix location to $HOME/.local/share/wineprefix/default
install -Dm644 -o root -g root default-prefix.fish /etc/fish/conf.d/wine-default_prefix.fish
install -Dm644 -o root -g root default-prefix.sh /etc/profile.d/wine-default_prefix.sh

# Disable menu builder to avoid .desktop files mess in .local/share/applications
install -Dm644 -o root -g root menubuilder.fish /etc/fish/conf.d/wine-menubuilder.fish
install -Dm644 -o root -g root menubuilder.sh /etc/profile.d/wine-menubuilder.sh
