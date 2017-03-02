#!/bin/bash

zcat "${CWD}/patches/${PKGNAME}/resouce.cleanup.fixes.diff.gz" | \
    patch -p1 --verbose || exit 1
