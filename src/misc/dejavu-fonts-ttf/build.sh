#!/bin/sh

PKGNAME="dejavu-fonts-ttf"

if [[ "${CHECK_PACKAGE_VERSION}" == "true" ]]; then
    # check latest release version
    echo -en "${GREY}Check ${CYAN}${PKGNAME}${GREY} latest release:${CDEF} "
    DOWNLOAD="http://sourceforge.net/projects/dejavu/files/dejavu/"
    VERSION=$(links -dump https://dejavu-fonts.github.io/Download.html | \
        /bin/grep dejavu-fonts-ttf | /bin/grep .tar.bz2 | head -n 1 | rev | \
        cut -d . -f 3- | cut -d - -f 1 | rev)
    SOURCE="${PKGNAME}-${VERSION}.tar.bz2"
    echo "${VERSION}"

    # download source archive if does not exist
    if ! [ -r "${SOURCE}" ]; then
        echo -e "${YELLOW}Downloading ${SOURCE} source archive${CDEF}"
        wget "${DOWNLOAD}${VERSION}/${SOURCE}"
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
(
    cd fontconfig || exit 1
    for CONF in *; do
        cp -a "${CONF}" "${FONTS}/conf.avail"
        (
            cd "${FONTS}/conf.d" || exit 1
            ln -sf "../conf.avail/${CONF}" "${CONF}"
        )
    done
)

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
