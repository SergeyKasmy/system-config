#!/bin/bash

# use flat cursor acceleration profile
kwriteconfig5 --file 'kcminputrc' --group 'Mouse' --key 'XLbInptAccelProfileFlat' --type bool true

# turn on numlock automatically
kwriteconfig5 --file 'kcminputrc' --group 'Keyboard' --key 'NumLock' 0
