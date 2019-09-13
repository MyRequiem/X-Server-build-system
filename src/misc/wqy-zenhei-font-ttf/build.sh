#!/bin/sh

[[ "${ONLY_DOWNLOAD}" == "true" ]] && exit 0

PKGNAME="wqy-zenhei-font-ttf"
SRCNAM="wqy-zenhei"
VERSION=${VERSION:-0.8.38}
SUB=${SUB:-1}
CWD=$(pwd)
TMP="${TEMP}/misc"
PKG="${TMP}/package-${PKGNAME}"

SOURCE="${SRCNAM}-${VERSION}-${SUB}.tar.bz2"

rm -rf "${PKG}"
mkdir -p "${PKG}"
cd "${TMP}" || exit 1
rm -rf "${SRCNAM}"
tar xvf "${CWD}/${SOURCE}"
cd "${SRCNAM}" || exit 1
. "${CWDD}"/additional-scripts/setperm.sh

zcat "${CWD}/fixup-fontconfig-file.diff.gz" | patch -p1 --verbose || exit 1

TTF="${PKG}/usr/share/fonts/TTF/"
mkdir -p "${TTF}"
find . -type f -name "*.ttf" -exec cp -a {} "${TTF}" \;
find . -type f -name "*.ttc" -exec cp -a {} "${TTF}" \;

. "${CWDD}"/additional-scripts/copydocs.sh
mv "${PKG}/usr/doc/${PKGNAME}-${VERSION}" \
    "${PKG}/usr/doc/${PKGNAME}-${VERSION}_${SUB}"

FONTS="${PKG}/etc/fonts"
mkdir -p "${FONTS}"/conf.{d,avail}
find . -name "*.conf" -exec cp -a {} "${FONTS}/conf.avail" \;
(
    cd "${FONTS}/conf.d" || exit 1
    ln -sf ../conf.avail/44-wqy-zenhei.conf 44-wqy-zenhei.conf
)

mkdir -p "${PKG}/usr/sbin"
install -m755 zenheiset "${PKG}/usr/sbin/zenheiset"

mkdir -p "${PKG}/install"
cat "${CWD}/slack-desc" > "${PKG}/install/slack-desc"
cat "${CWD}/doinst.sh" > "${PKG}/install/doinst.sh"

cd "${PKG}" || exit 1
mkdir -p "${OUTPUT}/misc"
BUILD=$(cat "${CWDD}/build/${PKGNAME}" 2>/dev/null || echo "1")
PKG="${OUTPUT}/misc/${PKGNAME}-${VERSION}_${SUB}-noarch-${BUILD}${TAG}.${EXT}"
rm -f "${PKG}"
makepkg -l y -c n "${PKG}"

if [[ "${INSTALL_AFTER_BUILD}" == "true" ]]; then
    upgradepkg --install-new --reinstall "${PKG}"
fi
