#!/bin/bash

MANDIR="${PKG}/usr/man"
if [ -d "${MANDIR}" ]; then
    (
        cd "${MANDIR}" || exit 1
        # compress manpages, if any
        find . -type f -a ! -name "*.gz" -exec gzip -9 {} \;

        # recreate links, if any
        MANLINKS=$(find . -type l)
        for MANLINK in ${MANLINKS}; do
            ln -s "$(readlink "${MANLINK}").gz" "${MANLINK}".gz
            rm -f "${MANLINK}"
        done
    )
fi
