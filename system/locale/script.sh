#!/bin/sh
# Set default system locale

install -Dm644 -o root -g root locale.conf /etc/locale.conf
