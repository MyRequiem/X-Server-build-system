#!/bin/bash

./configure \
    --prefix=/usr \
    --libdir=/usr/lib"${LIBDIRSUFFIX}" \
    --sysconfdir=/etc \
    --localstatedir=/var \
    --infodir=/usr/info \
    --mandir=/usr/man \
    --disable-static \
    --enable-xkbcomp-symlink \
    --enable-compat-rules \
    --with-xkb-base=/etc/X11/xkb \
    --with-xkb-rules-symlink=xfree86,xorg \
    --build="${ARCH}"-slackware-linux
