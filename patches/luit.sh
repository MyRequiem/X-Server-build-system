#!/bin/bash

zcat "${CWD}/patches/${PKGNAME}/luit_use_system_extensions.diff.gz" | \
    patch -p1 --verbose || exit 1

autoreconf -v -i -f
