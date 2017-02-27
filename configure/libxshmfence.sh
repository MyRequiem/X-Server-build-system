#!/bin/bash

# of course, the libtool stuff included in the
# tarball is broken, so we make autoreconf :)
autoreconf -v -i -f

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
    --disable-static \
    --build="${ARCH}"-slackware-linux
