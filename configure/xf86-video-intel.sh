#!/bin/bash

CFLAGS="${SLKCFLAGS}" \
CXXFLAGS="${SLKCFLAGS}" \
./autogen.sh \
    --prefix=/usr \
    --libdir=/usr/lib"${LIBDIRSUFFIX}" \
    --sysconfdir=/etc \
    --localstatedir=/var \
    --infodir=/usr/info \
    --mandir=/usr/man \
    --docdir=/usr/doc/"${PKGNAME}-${VERSION}" \
    --disable-static \
    --enable-kms-only \
    --enable-uxa \
    --build="${ARCH}"-slackware-linux
