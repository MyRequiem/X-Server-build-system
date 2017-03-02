#!/bin/bash

# LP is truly a one-man disaster...
zcat "${CWD}/patches/${PKGNAME}/xinit.remove.systemd.kludge.diff.gz" | \
    patch -p1 || exit 1
