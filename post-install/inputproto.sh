#!/bin/bash

DOCS="${PKG}/usr/doc/${PKGNAME}-${VERSION}"
mkdir -p "${DOCS}/html"
mv "${DOCS}"/*.html "${DOCS}/html"
