#!/bin/sh

PKGNAME="glew"

if [[ "${CHECK_PACKAGE_VERSION}" == "true" ]]; then
    # check latest release version
    echo -en "${GREY}Check ${CYAN}${PKGNAME}${GREY} latest release:${CDEF} "
    VERSION=$(wget -q -O - http://glew.sourceforge.net/ | \
        grep -A 1 "The latest release is" | tail -n 1 | \
        cut -d ">" -f 2 | cut -d "<" -f 1)
    SOURCE="${PKGNAME}-${VERSION}.tar.gz"
    echo "${VERSION}"

    # download source archive if does not exist
    if ! [ -r "${SOURCE}" ]; then
        echo -e "${YELLOW}Downloading ${SOURCE} source archive${CDEF}"
        URL="https://sourceforge.net/projects/${PKGNAME}/files/${PKGNAME}"
        wget "${URL}/${VERSION}/${PKGNAME}-${VERSION}.tgz"
        mv "${PKGNAME}-${VERSION}.tgz" "${SOURCE}"
    fi
else
    SOURCE=$(ls "${PKGNAME}"-*.tar.?z*)
    VERSION=$(echo "${SOURCE}" | rev | cut -d - -f 1 | cut -d . -f 3- | rev)
fi

[[ "${ONLY_DOWNLOAD}" == "true" ]] && exit 0

CWD=$(pwd)
TMP="${TMP}/misc"
PKG="${TMP}/package-${PKGNAME}"

rm -rf "${PKG}"
mkdir -p "${PKG}"
cd "${TMP}" || exit 1
rm -rf "${PKGNAME}-${VERSION}"
tar xvf "${CWD}/${SOURCE}"
cd "${PKGNAME}-${VERSION}" || exit 1
. "${CWDD}"/additional-scripts/setperm.sh

# remove the DOS linefeeds from config.guess
TEMPFILE=$(mktemp)
fromdos < config/config.guess > "${TEMPFILE}"
cat "${TEMPFILE}" > config/config.guess
rm -f "${TEMPFILE}"

make "${NUMJOBS}" OPT="${SLKCFLAGS}"  || make OPT="${SLKCFLAGS}" || exit 1
make install.all GLEW_DEST="${PKG}/usr" || exit 1

LIB="${PKG}/usr/lib"
if [[  "${LIBDIRSUFFIX}" == "64" && -d "${LIB}" ]]; then
    mv "${LIB}"/* "${PKG}/usr/lib${LIBDIRSUFFIX}"
    rm -rf "${LIB}"
fi

chmod 755 "${PKG}/usr/lib${LIBDIRSUFFIX}"/libGLEW*.so.*
rm -f "${PKG}/usr/lib${LIBDIRSUFFIX}"/libGLEW*.a

. "${CWDD}"/additional-scripts/strip-binaries.sh
. "${CWDD}"/additional-scripts/copydocs.sh

mkdir -p "${PKG}/install"
cat "${CWD}/slack-desc" > "${PKG}/install/slack-desc"

cd "${PKG}" || exit 1
mkdir -p "${OUTPUT}/misc"
BUILD=$(cat "${CWDD}/build/${PKGNAME}")
PKG="${OUTPUT}/misc/${PKGNAME}-${VERSION}-${ARCH}-${BUILD}_${TAG}.${EXT}"
rm -f "${PKG}"
makepkg -l y -c n "${PKG}"

if [[ "${INSTALL_AFTER_BUILD}" == "true" ]]; then
    upgradepkg --install-new --reinstall "${PKG}"
fi
