#!/bin/sh

[[ "${ONLY_DOWNLOAD}" == "true" ]] && exit 0

PKGNAME="sinhala_lklug-font-ttf"
VERSION=${VERSION:-20060929}

CWD=$(pwd)
TMP="${TEMP}/misc"
PKG="${TMP}/package-${PKGNAME}"

rm -rf "${PKG}"
mkdir -p "${PKG}"
cd "${PKG}" || exit 1

TTF="${PKG}/usr/share/fonts/TTF/"
mkdir -p "${TTF}"
cp "${CWD}/sinhala_lklug.ttf" "${TTF}"/
chown root:root "${TTF}"/*
chmod 644 "${TTF}"/*

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
