#!/bin/sh

PKGNAME="xterm"

if [[ "${CHECK_PACKAGE_VERSION}" == "true" ]]; then
    # check latest release version
    echo -en "${GREY}Check ${CYAN}${PKGNAME}${GREY} latest release:${CDEF} "
    DOWNLOAD="http://invisible-mirror.net/archives/xterm/"
    VERSION=$(wget -q -O - "${DOWNLOAD}" | grep 'href="xterm-' | \
        grep '.tgz"' | cut -d \" -f 2 | rev | cut -d - -f 1 | \
        cut -d . -f 2- | rev | sort -V | tail -n 1)
    SOURCE="${PKGNAME}-${VERSION}.tar.gz"
    echo "${VERSION}"

    # download source archive if does not exist
    if ! [ -r "${SOURCE}" ]; then
        echo -e "${YELLOW}Downloading ${SOURCE} source archive${CDEF}"
        ARCHIVE="${PKGNAME}-${VERSION}.tgz"
        wget "${DOWNLOAD}${ARCHIVE}"
        mv "${ARCHIVE}" "${SOURCE}"
    fi
else
    SOURCE=$(find . -type f -name "${PKGNAME}-[0-9]*.tar.?z*" | head -n 1 | \
        rev | cut -d / -f 1 | rev)
    VERSION=$(echo "${SOURCE}" | rev | cut -d - -f 1 | cut -d . -f 3- | rev)
fi

[[ "${ONLY_DOWNLOAD}" == "true" ]] && exit 0

CWD=$(pwd)
TMP="${TEMP}/misc"
PKG="${TMP}/package-${PKGNAME}"

rm -rf "${PKG}"
mkdir -p "${PKG}"
cd "${TMP}" || exit 1
rm -rf "${PKGNAME}-${VERSION}"
tar xvf "${CWD}/${SOURCE}"
cd "${PKGNAME}-${VERSION}" || exit 1
. "${CWDD}"/additional-scripts/setperm.sh

CFLAGS="${SLKCFLAGS}" \
./configure \
    --prefix=/usr \
    --sysconfdir=/etc \
    --localstatedir=/var \
    --infodir=/usr/info \
    --mandir=/usr/man \
    --with-app-defaults=/etc/X11/app-defaults \
    --with-utempter \
    --enable-luit \
    --enable-wide-chars \
    --enable-88-color \
    --enable-256-color \
    --with-icon-theme=hicolor \
    --with-icondir=/usr/share/icons \
    --with-pixmapdir=/usr/share/pixmaps \
    --build="${ARCH}"-slackware-linux || exit 1

make "${NUMJOBS}" || make || exit 1
make install DESTDIR="${PKG}" || exit 1

. "${CWDD}"/additional-scripts/strip-binaries.sh
. "${CWDD}"/additional-scripts/copydocs.sh
. "${CWDD}"/additional-scripts/compressmanpages.sh

APPLICATIONS="${PKG}/usr/share/applications"
for DESKTOP in xterm.desktop uxterm.desktop; do
    if [[ -r "./${DESKTOP}" && ! -f "${APPLICATIONS}/${DESKTOP}" ]]; then
        mkdir -p "${APPLICATIONS}"
        cp "${DESKTOP}" "${APPLICATIONS}"
    fi
done

mkdir -p "${PKG}/install"
cat "${CWD}/slack-desc" > "${PKG}/install/slack-desc"
cat "${CWD}/doinst.sh" > "${PKG}/install/doinst.sh"

cd "${PKG}" || exit 1
mkdir -p "${OUTPUT}/misc"
BUILD=$(cat "${CWDD}/build/${PKGNAME}" 2>/dev/null || echo "1")
PKG="${OUTPUT}/misc/${PKGNAME}-${VERSION}-${ARCH}-${BUILD}_${TAG}.${EXT}"
rm -f "${PKG}"
makepkg -l y -c n "${PKG}"

if [[ "${INSTALL_AFTER_BUILD}" == "true" ]]; then
    upgradepkg --install-new --reinstall "${PKG}"
fi
