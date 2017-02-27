#!/bin/bash

# create conf dirs
mkdir -p "${PKG}/etc/X11/xorg.conf.d" \
    "${PKG}/usr/share/X11/xorg.conf.d"

# don't mess with /var/log/ permissions:
VARLOG="${PKG}/var/log"
if [ -d "${VARLOG}" ]; then
    rm -rf "${VARLOG}"
fi

# correct link to xorg modules
(
    cd "${PKG}/usr/lib" || exit 1
    rm -rf modules
    ln -sf xorg/modules modules
)
