#!/bin/bash

CFLAGS="${SLKCFLAGS}" \
CXXFLAGS="${SLKCFLAGS}" \
./configure \
    --prefix=/usr \
    --libdir=/usr/lib"${LIBDIRSUFFIX}" \
    --sysconfdir=/etc \
    --localstatedir=/var \
    --infodir=/usr/info \
    --mandir=/usr/man \
    --with-fontrootdir=/usr/share/fonts \
    --disable-static \
    --build="${ARCH}"-slackware-linux
