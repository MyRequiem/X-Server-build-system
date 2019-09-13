#!/bin/sh

[[ "${ONLY_DOWNLOAD}" == "true" ]] && exit 0

PKGNAME="ttf-indic-fonts"
VERSION="0.5.14"
CWD=$(pwd)
TMP="${TEMP}/misc"
PKG="${TMP}/package-${PKGNAME}"

rm -rf "${PKG}"
mkdir -p "${PKG}"
cd "${TMP}" || exit 1
rm -rf "${PKGNAME}-${VERSION}"
tar xvf "${CWD}/${PKGNAME}_${VERSION}.tar.xz"
cd "${PKGNAME}-${VERSION}" || exit 1
. "${CWDD}"/additional-scripts/setperm.sh

TTF="${PKG}/usr/share/fonts/TTF/"
mkdir -p "${TTF}"
find . -type f -name "*.ttf" -exec cp -a {} "${TTF}" \;


FONTS="${PKG}/etc/fonts"
mkdir -p "${FONTS}"/conf.{d,avail}
find . -name "*.conf" -exec cp -a {} "${FONTS}/conf.avail" \;

(
    cd "${FONTS}/conf.avail" || exit 1
    for CONF in *; do
        (
            cd "${FONTS}/conf.d" || exit 1
            ln -sf "../conf.avail/${CONF}" "${CONF}"
        )
    done
)

mkdir -p "${PKG}/usr/doc/${PKGNAME}-${VERSION}"
find . -name "*.copyright" -exec \
    cp -a {} "${PKG}/usr/doc/${PKGNAME}-${VERSION}" \;

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
