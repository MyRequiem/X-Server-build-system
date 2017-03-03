#!/bin/sh

if [[ -x /usr/bin/mkfontdir || -x /usr/X11R6/bin/mkfontdir ]]; then
    (
        cd /usr/share/fonts/misc || exit 1
        mkfontscale .
        mkfontdir -e /usr/share/fonts/encodings \
            -e /usr/share/fonts/encodings/large .
    )
fi

if [ -x /usr/bin/fc-cache ]; then
    /usr/bin/fc-cache -f
fi
