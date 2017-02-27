#!/bin/bash

(
    cd "${PKG}"/usr/lib || exit 1
    ln -sf libxcb.so.1 libxcb-xlib.so.0
    ln -sf libxcb-xlib.so.0 libxcb-xlib.so
    ln -sf libxcb.la libxcb-xlib.la
)
