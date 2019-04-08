#!/bin/bash

rm -f "${PKG}/usr/share/X11/xorg.conf.d/50-synaptics.conf"

mkdir -p "${PKG}/usr/doc/${PKGNAME}-${VERSION}"
cp -a README TODO "${PKG}/usr/doc/${PKGNAME}-${VERSION}"
