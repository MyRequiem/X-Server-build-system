#!/bin/bash

DOCS="AUTHORS COPYING* INSTALL NEWS README* TODO ChangeLog*"
DOCDIR="${PKG}/usr/doc/${PKGNAME}-${VERSION}"

# txt docs
for DOC in ${DOCS}; do
    if [[ -r "${DOC}" && "$(stat -c%s "${DOC}")" != "0" ]]; then
        mkdir -p "${DOCDIR}"
        cp -v "${DOC}" "${DOCDIR}"
    fi
done

# html docs
if [ -d doc/ ]; then
    HTML=$(find doc/ -maxdepth 1 -type f -a \
        \( -name "*.html" -o -name "*.htm" \))
    if [[ "x${HTML}" != "x" ]]; then
        mkdir -p "${DOCDIR}/html"
        cp -v doc/*.{html,htm,png} "${DOCDIR}/html" 2>/dev/null
    fi
fi

# chmod 644 for all docs files
if [ -d "${DOCDIR}" ]; then
    chmod -R 644 "${DOCDIR}"/*
fi
