#!/bin/bash

(
    cd "${PKG}/usr/lib" || exit 1
    ln -sf libXaw.so.7 libXaw.so.8
)

rm -f "${PKG}/usr/doc/${PKGNAME}-${VERSION}"/*.xml
