#!/bin/bash

if [ "${ARCH}" = "x86_64" ]; then
    DO_SSE2="--enable-sse2"
else
    DO_SSE2="--disable-sse2"
fi

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
    --disable-vmx \
    --build="${ARCH}"-slackware-linux \
    ${DO_SSE2}
