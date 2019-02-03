#!/bin/bash

# do not copy selection to the clipboard
kwriteconfig5 --file 'klipperrc' --group 'General' --key 'IgnoreSelection' --type bool true
