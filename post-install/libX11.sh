#!/bin/bash

mkdir -p "${PKG}"/usr/share/X11
zcat "${CWD}"/post-install/libX11/XKeysymDB.gz > \
    "${PKG}"/usr/share/X11/XKeysymDB

DIRS="XIM XKB i18n libX11"
for DIR in ${DIRS}; do
    [ -d "${PKG}/usr/doc/${PKGNAME}-${VERSION}/${DIR}" ] &&
        rm -rf "${PKG}/usr/doc/${PKGNAME}-${VERSION}/${DIR}"
done
