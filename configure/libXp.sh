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
    --disable-static \
    --docdir=/usr/doc/"${PKGNAME}-${VERSION}" \
    --build="${ARCH}"-slackware-linux
