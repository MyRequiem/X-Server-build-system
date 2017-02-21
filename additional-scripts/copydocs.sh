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
        cp "${DOC}" "${DOCDIR}"
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
        cp "${DOCD}"/*.{html,htm,png} "${DOCDIR}/html" 2>/dev/null
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
SHARE="${PKG}/usr/share"
if [ -d "${SHARE}/doc" ]; then
    mkdir -p "${DOCDIR}"
    mv "${SHARE}"/doc/* "${DOCDIR}"
    rm -rf "${SHARE}/doc"
    # if "${PKG}/usr/share" directory is empty, remove it
    if [[ "$(find "${SHARE}" | wc -l)" == "1" ]]; then
        rm -rf "${SHARE}"
    fi
fi

# chmod for all docs and info files
if [ -d "${DOCDIR}" ]; then
    find "${DOCDIR}" -type d -exec chmod 755 {} \;
    find "${DOCDIR}" -type f -exec chmod 644 {} \;
fi
