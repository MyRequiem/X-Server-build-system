#!/bin/bash

# compress manpages, if any
MANDIR="${PKG}/usr/man"
if [ -d "${MANDIR}" ]; then
    (
        cd "${MANDIR}" || exit 1
        MANPAGEDIRS=$(find . -maxdepth 1 -type d -name "man*")
        for MANPAGEDIR in ${MANPAGEDIRS}; do
            (
                cd "${MANPAGEDIR}" || exit 1
                PAGES=$(find . -type f -maxdepth 1 ! -name "*.gz")
                for PAGE in ${PAGES}; do
                    gzip "${PAGE}"
                done
            )
        done
    )
fi
