#!/bin/sh

file=/etc/pacman.conf

if [ -e "$file" ]; then
	sed -i '/^#Color/s/^#//' "$file"
	sed -i '/^#TotalDownload/s/^#//' "$file"
	sed -i '/^#VerbosePkgLists/s/^#//' "$file"
fi
