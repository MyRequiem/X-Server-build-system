#!/bin/bash

mkdir -p "${PKG}/usr/share/X11"
(
    cd "${PKG}/usr/share/X11" || exit 1
    ln -sf ../../../etc/X11/xkb xkb
)
