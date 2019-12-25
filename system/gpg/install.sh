#!/bin/sh
# Set default location/home for GPG conf

install -Dm644 -o root -g root default-home.sh /etc/profile.d/gpg-home.sh
install -Dm644 -o root -g root default-home.fish /etc/fish/conf.d/gpg-home.fish
