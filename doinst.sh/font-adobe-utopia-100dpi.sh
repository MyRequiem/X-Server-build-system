#!/bin/sh

if [[ -x /usr/bin/mkfontdir || -x /usr/X11R6/bin/mkfontdir ]]; then
    (
        cd /usr/share/fonts/100dpi || exit 1
        mkfontscale .
        mkfontdir .
    )
fi

if [ -x /usr/bin/fc-cache ]; then
    /usr/bin/fc-cache -f
fi
