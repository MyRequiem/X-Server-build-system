#!/bin/sh

PKGNAME="mesa-demos"

if [[ "${CHECK_PACKAGE_VERSION}" == "true" ]]; then
    # check latest release version
    echo -en "${GREY}Check ${CYAN}${PKGNAME}${GREY} latest release:${CDEF} "
    URL="https://mesa.freedesktop.org/archive/demos/"
    VERSION=$(wget -q -O - "${URL}" | grep "href=" | grep "/folder.gif" | \
        cut -d \" -f 8 | cut -d / -f 1 | sort -V | tail -n 1)
    SOURCE="${PKGNAME}-${VERSION}.tar.bz2"
    echo "${VERSION}"

    if ! [ -r "${SOURCE}" ]; then
        echo -e "${YELLOW}Download ${PKGNAME} source archive${CDEF}"
        wget "${URL}${VERSION}/${SOURCE}"
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

cd "${TMP}" || exit 1
rm -rf "${PKGNAME}-${VERSION}"
tar xvf "${CWD}/${SOURCE}" || exit 1
cd "${PKGNAME}-${VERSION}" || exit 1
. "${CWDD}"/additional-scripts/setperm.sh

CFLAGS="${SLKCFLAGS}" \
./configure \
    --prefix=/usr \
    --build="${ARCH}"-slackware-linux

# build and install gears and glinfo, as well as a few other demos
BIN="${PKG}/usr/bin"
mkdir -p "${BIN}"
make -C src/demos gears glinfo || exit 1
cp -a src/demos/{gears,glinfo} "${BIN}"

XDEMOS="glthreads glxcontexts glxdemo glxgears glxgears_fbconfig glxheads \
    glxinfo glxpbdemo glxpixmap"
for XDEMO in ${XDEMOS}; do
    if [ -r "src/xdemos/${XDEMO}.c" ]; then
        make -C src/xdemos "${XDEMO}" || exit 1
        cp -a src/xdemos/"${XDEMO}" "${BIN}"
    fi
done

. "${CWDD}"/additional-scripts/strip-binaries.sh

DOC="${PKG}/usr/doc/${PKGNAME}-${VERSION}"
mkdir -p "${DOC}"
cat "${CWD}"/info > "${DOC}"/info

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
