#!/bin/bash

X11="${PKG}/usr/share/fonts/X11"
if [ -d "${X11}" ]; then
    mv "${X11}"/* "${PKG}/usr/share/fonts/"
    rm -rf "${X11}"
fi
