#!/bin/sh

PKGNAME="mtdev"

if [[ "${CHECK_PACKAGE_VERSION}" == "true" ]]; then
    # check latest release version
    echo -en "${GREY}Check ${CYAN}${PKGNAME}${GREY} latest release:${CDEF} "
    URL="http://bitmath.org/code/mtdev/"
    VERSION=$(wget -q -O - "${URL}" | grep "${PKGNAME}" | grep ".tar.bz2" | \
        head -n 1 | cut -d - -f 3 | rev | cut -d . -f 3- | rev)
    SOURCE="${PKGNAME}-${VERSION}.tar.bz2"
    echo "${VERSION}"

    if ! [ -r "${SOURCE}" ]; then
        echo -e "${YELLOW}Clone and creating ${SOURCE} source archive${CDEF}"
        wget "${URL}${SOURCE}"
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
CXXFLAGS="${SLKCFLAGS}" \
./configure \
    --prefix=/usr \
    --libdir=/usr/lib"${LIBDIRSUFFIX}" \
    --sysconfdir=/etc \
    --localstatedir=/var \
    --mandir=/usr/man \
    --docdir=/usr/doc/"${PKGNAME}-${VERSION}" \
    --build="${ARCH}"-slackware-linux \
    --disable-static

make "${NUMJOBS}" || make || exit 1
make install DESTDIR="${PKG}" || exit 1

. "${CWDD}"/additional-scripts/strip-binaries.sh
. "${CWDD}"/additional-scripts/copydocs.sh
. "${CWDD}"/additional-scripts/compressmanpages.sh

mkdir -p "${PKG}"/install
cat "${CWD}"/slack-desc > "${PKG}"/install/slack-desc

cd "${PKG}" || exit 1
mkdir -p "${OUTPUT}/misc"
BUILD=$(cat "${CWDD}/build/${PKGNAME}" 2>/dev/null || echo "1")
PKG="${OUTPUT}/misc/${PKGNAME}-${VERSION}-${ARCH}-${BUILD}_${TAG}.${EXT}"
rm -f "${PKG}"
makepkg -l y -c n "${PKG}"

if [[ "${INSTALL_AFTER_BUILD}" == "true" ]]; then
    upgradepkg --install-new --reinstall "${PKG}"
fi
