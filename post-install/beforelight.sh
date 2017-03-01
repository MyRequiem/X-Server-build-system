#!/bin/bash

# DESTDIR is seriously broken on this one, but since nobody
# knows what it's for that's probably why it isn't noticed.
ERRORDESTDIR="${PKG}/tmp/x11-build/package-beforelight/etc/X11/app-defaults"
if [ -d "${ERRORDESTDIR}" ]; then
    CORRECTDIR="${PKG}/etc/X11/app-defaults"
    mkdir -p "${CORRECTDIR}"
    mv "${ERRORDESTDIR}/Beforelight" "${CORRECTDIR}"
    rm -rf "${PKG}/tmp"
fi
