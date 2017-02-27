#!/bin/bash

X11="${PKG}/etc/X11"
mkdir -p "${X11}/xinit"

(
    libX11="${PKG}/usr/lib/X11"
    mkdir -p "${libX11}"
    cd "${libX11}" || exit 1
    ln -sf ../../../etc/X11/xinit xinit
)

MODMAP="README.Xmodmap"
XINIT="${X11}/xinit"
cp -a "${CWD}/post-install/xinit/${MODMAP}" "${XINIT}"
chown root:root "${XINIT}/${MODMAP}"
chmod 644 "${XINIT}/${MODMAP}"

rm -f "${XINIT}/xinitrc"
