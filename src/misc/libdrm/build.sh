#!/bin/sh

PKGNAME="libdrm"

if [[ "${CHECK_PACKAGE_VERSION}" == "true" ]]; then
    DOWNLOADPAGE="https://dri.freedesktop.org/libdrm"
    # check latest release version
    echo -en "${GREY}Check ${PKGNAME} latest release:${CDEF} "
    VERSION=$(wget -q -O - "${DOWNLOADPAGE}" | grep '.tar.bz2"' | \
        cut -d \" -f 8 | cut -d - -f 2 | rev | cut -d . -f 3- | rev | \
        sort -V | tail -n 1)
    SOURCE="${PKGNAME}-${VERSION}.tar.bz2"
    echo "${VERSION}"

    # download source archive if does not exist
    if ! [ -r "${SOURCE}" ]; then
        echo -e "${YELLOW}Downloading ${SOURCE} source archive${CDEF}"
        wget "${DOWNLOADPAGE}/${SOURCE}"
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

CFLAGS="$SLKCFLAGS" \
./configure \
    --prefix=/usr \
    --libdir=/usr/lib"${LIBDIRSUFFIX}" \
    --mandir=/usr/man \
    --enable-udev \
    --build="${ARCH}"-slackware-linux

make "${NUMJOBS}" || make || exit 1
make install DESTDIR="${PKG}" || exit 1

. "${CWDD}"/strip-binaries.sh

# compress manpages, if any
MANDIR="${PKG}/usr/man"
if [ -d "${MANDIR}" ]; then
    (
        cd "${MANDIR}" || exit 1
        MANPAGEDIRS=$(find . -maxdepth 1 -type d -name "man*")
        for MANPAGEDIR in ${MANPAGEDIRS}; do
            (
                cd "${MANPAGEDIR}" || exit 1
                PAGES=$(find . -type f -maxdepth 1)
                for PAGE in ${PAGES}; do
                    gzip "${PAGE}"
                done
            )
        done
    )
fi

DOCDIR="${PKG}/usr/doc/${PKGNAME}-${VERSION}"
mkdir -p "${DOCDIR}"
for DOC in ${DOCS}; do
    if [ -r "${DOC}" ]; then
        cp "${DOC}" "${DOCDIR}"
    fi
done

mkdir -p "${PKG}/install"
cat "${CWD}/slack-desc" > "${PKG}/install/slack-desc"

cd "${PKG}" || exit 1
mkdir -p "${OUTPUT}/misc"
BUILD=$(cat "${CWDD}/build/${PKGNAME}")
PKG="${OUTPUT}/misc/${PKGNAME}-${VERSION}-${ARCH}-${BUILD}_${TAG}.${EXT}"
rm -f "${PKG}"
makepkg -l y -c n "${PKG}"

if [[ "${INSTALL_AFTER_BUILD}" == "true" ]]; then
    upgradepkg --install-new --reinstall "${PKG}"
fi
