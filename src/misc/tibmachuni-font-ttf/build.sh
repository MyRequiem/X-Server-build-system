#!/bin/sh

[[ "${ONLY_DOWNLOAD}" == "true" ]] && exit 0

PKGNAME="tibmachuni-font-ttf"
VERSION=${VERSION:-1.901b}
ARCHNAME="TibetanMachineUnicodeFont"

CWD=$(pwd)
TMP="${TEMP}/misc"
PKG="${TMP}/package-${PKGNAME}"

rm -rf "${PKG}"
mkdir -p "${PKG}"
cd "${TMP}" || exit 1
rm -rf ${ARCHNAME}
unzip "${CWD}/${ARCHNAME}.zip" || exit 1
cd "${ARCHNAME}" || exit 1
. "${CWDD}"/additional-scripts/setperm.sh

TTF="${PKG}/usr/share/fonts/TTF/"
mkdir -p "${TTF}"
cp "TibMachUni-${VERSION}.ttf" "${TTF}/TibMachUni.ttf"

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
