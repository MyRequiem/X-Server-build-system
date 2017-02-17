#!/bin/sh

PKGNAME="glu"

if [[ "${CHECK_PACKAGE_VERSION}" == "true" ]]; then
    # check latest release version
    echo -en "${GREY}Check ${PKGNAME} latest release:${CDEF} "
    VERSION=$(wget -q -O - http://cgit.freedesktop.org/mesa/glu/ | \
        grep -A 1 Download | tail -n 1 | cut -d / -f 5 | rev | cut -d - -f 1 | \
        rev | cut -d "<" -f 1)
    SOURCE="${PKGNAME}-${VERSION}.tar.xz"
    echo "${VERSION}"

    if ! [ -r "${SOURCE}" ]; then
        echo -e "${YELLOW}Clone and creating ${SOURCE} source archive${CDEF}"
        git clone git://anongit.freedesktop.org/mesa/glu
        mv "${PKGNAME}" "${PKGNAME}-${VERSION}"
        tar cJvf "${SOURCE}" "${PKGNAME}-${VERSION}"
        rm -rf "${PKGNAME}-${VERSION}"
    fi
else
    SOURCE=$(ls "${PKGNAME}-"*.tar.?z*)
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
. "${CWDD}"/setperm.sh

if ! [ -x ./configure ]; then
    ./autogen.sh
fi

CFLAGS="${SLKCFLAGS}" \
CXXFLAGS="${SLKCFLAGS}" \
./configure \
    --disable-static \
    --prefix=/usr \
    --libdir=/usr/lib"${LIBDIRSUFFIX}" \
    --sysconfdir=/etc \
    --localstatedir=/var \
    --build="${ARCH}"-slackware-linux || exit 1

make "${NUMJOBS}" || make || exit 1
make install DESTDIR="${PKG}" || exit 1

. "${CWDD}"/strip-binaries.sh

mkdir -p "${PKG}"/install
cat "${CWD}"/slack-desc > "${PKG}"/install/slack-desc

cd "${PKG}" || exit 1
mkdir -p "${OUTPUT}/misc"
BUILD=$(cat "${CWDD}/build/${PKGNAME}")
PKG="${OUTPUT}/misc/${PKGNAME}-${VERSION}-${ARCH}-${BUILD}_${TAG}.${EXT}"
rm -f "${PKG}"
makepkg -l y -c n "${PKG}"

if [[ "${INSTALL_AFTER_BUILD}" == "true" ]]; then
    upgradepkg --install-new --reinstall "${PKG}"
fi
