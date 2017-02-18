#!/bin/bash

DOCS="AUTHORS COPYING* INSTALL NEWS README* TODO ChangeLog* VERSION\
    doc/AUTHORS doc/COPYING* doc/INSTALL doc/NEWS doc/README* doc/TODO \
    doc/ChangeLog* doc/GL* doc/VERSION docs/AUTHORS docs/COPYING* \
    docs/INSTALL docs/NEWS docs/README* docs/TODO docs/ChangeLog* docs/GL* \
    docs/VERSION"
DOCDIR="${PKG}/usr/doc/${PKGNAME}-${VERSION}"

# txt docs
for DOC in ${DOCS}; do
    if [[ -r "${DOC}" && "$(stat -c%s "${DOC}")" != "0" ]]; then
        mkdir -p "${DOCDIR}"
        cp -v "${DOC}" "${DOCDIR}"
    fi
done

# html docs
if [[ -d doc || -d docs ]]; then
    DOCD="doc"
    [ -d docs ] && DOCD="docs"
    HTML=$(find "${DOCD}" -maxdepth 1 -type f -a \
        \( -name "*.html" -o -name "*.htm" \))

    if [[ "x${HTML}" != "x" ]]; then
        mkdir -p "${DOCDIR}/html"
        cp -v "${DOCD}"/*.{html,htm,png} "${DOCDIR}/html" 2>/dev/null
    fi
fi

# compress info files, if any:
INFODIR="${PKG}/usr/info"
if [ -d "${INFODIR}" ]; then
    rm -rf "${INFODIR}/dir"
    gzip -9 "${INFODIR}"/*
    chmod -R 644 "${INFODIR}"/*
fi

# if there are docs, move them:
SHAREDOC="${PKG}/usr/share/doc"
if [ -d "${SHAREDOC}" ]; then
    mkdir -p "${DOCDIR}"
    mv "${SHAREDOC}"/* "${DOCDIR}"
    rm -rf "${SHAREDOC}"
fi

# chmod 644 for all docs and info files
if [ -d "${DOCDIR}" ]; then
    chmod -R 644 "${DOCDIR}"/*
fi
