#!/bin/bash

mkdir -p "${PKG}/usr/lib"
mv "${PKG}/usr/share/pkgconfig" "${PKG}/usr/lib"
