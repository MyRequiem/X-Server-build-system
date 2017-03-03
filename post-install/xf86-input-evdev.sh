#!/bin/bash

EVDEVCONF="${PKG}/usr/share/X11/xorg.conf.d/10-evdev.conf"
if [ -f "${EVDEVCONF}" ]; then
    rm -f "${EVDEVCONF}"
fi
