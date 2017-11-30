#!/bin/bash

zcat "${CWD}/patches/${PKGNAME}/libXfont.CVE-2017-16611.diff.gz" | \
    patch -p1 --verbose || exit 1
