#!/bin/sh

PKGNAME="liberation-fonts-ttf"

if [[ "${CHECK_PACKAGE_VERSION}" == "true" ]]; then
    # check latest release version
    echo -en "${GREY}Check ${CYAN}${PKGNAME}${GREY} latest release:${CDEF} "
    DOWNLOAD="http://ftp.nsysu.edu.tw/FreeBSD/ports/local-distfiles/thierry/"
    VERSION=$(wget -q -O - "${DOWNLOAD}" | grep "${PKGNAME}" | \
        grep ".tar.gz" | cut -d \" -f 7 | cut -d - -f 4 | rev | \
        cut -d . -f 3- | rev | sort -V | tail -n 1)
    SOURCE="${PKGNAME}-${VERSION}.tar.gz"
    echo "${VERSION}"

    # download source archive if does not exist
    if ! [ -r "${SOURCE}" ]; then
        echo -e "${YELLOW}Downloading ${SOURCE} source archive${CDEF}"
        wget "${DOWNLOAD}${SOURCE}"
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

TTF="${PKG}/usr/share/fonts/TTF/"
mkdir -p "${TTF}"
find . -type f -name "*.ttf" -exec cp -a {} "${TTF}" \;

. "${CWDD}"/additional-scripts/copydocs.sh

FONTS="${PKG}/etc/fonts"
mkdir -p "${FONTS}"/conf.{d,avail}
cat "${CWD}/60-liberation.conf" > "${FONTS}/conf.avail/60-liberation.conf"
(
    cd "${FONTS}/conf.d" || exit 1
    ln -sf ../conf.avail/60-liberation.conf 60-liberation.conf
)

mkdir -p "${PKG}/install"
cat "${CWD}/slack-desc" > "${PKG}/install/slack-desc"
cat "${CWD}/doinst.sh" > "${PKG}/install/doinst.sh"

cd "${PKG}" || exit 1
mkdir -p "${OUTPUT}/misc"
BUILD=$(cat "${CWDD}/build/${PKGNAME}" 2>/dev/null || echo "1")
PKG="${OUTPUT}/misc/${PKGNAME}-${VERSION}-noarch-${BUILD}_${TAG}.${EXT}"
rm -f "${PKG}"
makepkg -l y -c n "${PKG}"

if [[ "${INSTALL_AFTER_BUILD}" == "true" ]]; then
    upgradepkg --install-new --reinstall "${PKG}"
fi
