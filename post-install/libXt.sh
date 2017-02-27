#!/bin/bash

LIBXT="${PKG}/usr/doc/${PKGNAME}-${VERSION}/${PKGNAME}"
[ -d "${LIBXT}" ] && rm -rf "${LIBXT}"
