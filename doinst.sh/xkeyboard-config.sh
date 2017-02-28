#!/bin/bash

if [ -d etc/X11/xkb/symbols/pc ]; then
    mv etc/X11/xkb etc/X11/xkb.old.bak.$$
    mkdir -p etc/X11/xkb/rules
fi

