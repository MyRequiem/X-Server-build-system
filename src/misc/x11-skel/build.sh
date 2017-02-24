#!/bin/sh

[[ "${ONLY_DOWNLOAD}" == "true" ]] && exit 0

PKGNAME="x11-skel"
VERSION="1.0"

CWD="$(pwd)"
TMP="${TMP}/misc"
PKG="${TMP}/package-${PKGNAME}"

rm -rf "${PKG}"
mkdir -p "${PKG}"
cd "${PKG}" || exit 1

mkdir -p "usr/X11R6"
(
    cd usr/X11R6 || exit 1
    DIRS="../bin ../include ../lib ../libexec ../man ../share"
    [[ "${ARCH}" == "x86_64" ]] && DIRS="${DIRS} ../lib64"
    for DIR in ${DIRS}; do
        mkdir -p "${DIR}" && ln -s "${DIR}" "$(basename "${DIR}")"
    done

)

X11="usr/lib${LIBDIRSUFFIX}/X11"
mkdir -p "${X11}" "usr/share/fonts"
(
    cd "${X11}" || exit 1
    ln -s ../../share/fonts fonts
)

(
    cd usr || exit 1
    ln -s X11R6 X11
)

(
    cd usr/bin || exit 1
    ln -s . X11
)

mkdir -p install
sed -e "s#lib/#lib${LIBDIRSUFFIX}/#g" \
    -e "s#lib #lib${LIBDIRSUFFIX} #g" \
    "${CWD}/slack-desc" > "${PKG}/install/slack-desc"

mkdir -p "${OUTPUT}/misc"
BUILD=$(cat "${CWDD}/build/${PKGNAME}")
PKG="${OUTPUT}/misc/${PKGNAME}-${VERSION}-noarch-${BUILD}_${TAG}.${EXT}"
rm -f "${PKG}"
makepkg -l y -c n "${PKG}"

if [[ "${INSTALL_AFTER_BUILD}" == "true" ]]; then
    upgradepkg --install-new --reinstall "${PKG}"
fi
