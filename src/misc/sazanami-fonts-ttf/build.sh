#!/bin/sh

PKGNAME="sazanami-fonts-ttf"
FONTNAME="sazanami"

if [[ "${CHECK_PACKAGE_VERSION}" == "true" ]]; then
    # check latest release version
    echo -en "${GREY}Check ${CYAN}${PKGNAME}${GREY} latest release:${CDEF} "
    DOWNLOAD="https://ja.osdn.net/projects/efont/"
    VERSION=$(wget -q -O - "${DOWNLOAD}" | /bin/grep "sazanami" | \
        /bin/grep "<a href=" | /bin/grep -v "<ul>" | cut -d ">" -f 2 | \
        cut -d " " -f 2 | cut -d "<" -f 1 | sort -V | tail -n 1)
    SOURCE="${FONTNAME}-${VERSION}.tar.bz2"
    echo "${VERSION}"

    # download source archive if does not exist
    if ! [ -r "${SOURCE}" ]; then
        echo -e "${YELLOW}Downloading ${SOURCE} source archive${CDEF}"
        DOWNLOAD="${DOWNLOAD}downloads/$(wget -q -O - "${DOWNLOAD}" | \
            /bin/grep "sazanami" | /bin/grep "<a href=" | \
            /bin/grep -v "<ul>" | cut -d / -f 5 | cut -d \" -f 1 | \
            sort -V | tail -n 1)"
        wget "${DOWNLOAD}/sazanami-${VERSION}.tar.bz2"
    fi
else
    SOURCE=$(find . -type f -name "${FONTNAME}-[0-9]*.tar.?z*" | head -n 1 | \
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
rm -rf "${FONTNAME}-${VERSION}"
tar xvf "${CWD}/${SOURCE}"
cd "${FONTNAME}-${VERSION}" || exit 1
. "${CWDD}"/additional-scripts/setperm.sh

TTF="${PKG}/usr/share/fonts/TTF/"
mkdir -p "${TTF}"
find . -maxdepth 1 -type f -name "*.ttf" -exec cp -a {} "${TTF}" \;

. "${CWDD}"/additional-scripts/copydocs.sh

mkdir -p "${PKG}/install"
cat "${CWD}/slack-desc" > "${PKG}/install/slack-desc"
cat "${CWD}/doinst.sh" > "${PKG}/install/doinst.sh"

cd "${PKG}" || exit 1
mkdir -p "${OUTPUT}/misc"
BUILD=$(cat "${CWDD}/build/${PKGNAME}" 2>/dev/null || echo "1")
PKG="${OUTPUT}/misc/${PKGNAME}-${VERSION}-noarch-${BUILD}${TAG}.${EXT}"
rm -f "${PKG}"
makepkg -l y -c n "${PKG}"

if [[ "${INSTALL_AFTER_BUILD}" == "true" ]]; then
    upgradepkg --install-new --reinstall "${PKG}"
fi
