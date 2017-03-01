#!/bin/bash

if [[ "${ARCH}" == "x86_64" ]]; then
    (
        cd "${PKG}/usr/lib/X11/config" || exit 1
        zcat "${CWD}/post-install/${PKGNAME}/x11.tmpl.lib64.kludge.diff.gz" | \
            patch -p1 || exit 1
    )
fi

# remove the empty host.def:
rm -f "${PKG}/usr/lib/X11/config/host.def"
