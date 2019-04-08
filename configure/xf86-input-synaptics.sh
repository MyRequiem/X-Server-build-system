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
    --docdir=/usr/doc/"${PKGNAME}-${VERSION}" \
    --with-udev-rules-dir=/lib/udev/rules.d \
    --disable-static \
    --build="${ARCH}"-slackware-linux
