#!/bin/bash

# we can't leave people with nothing, so we'll have to set a probable default:
if ! [ -r etc/X11/xinit/xinitrc ]; then
    (
        cd etc/X11/xinit || exit 1
        ln -sf xinitrc.kde xinitrc
    )
fi
