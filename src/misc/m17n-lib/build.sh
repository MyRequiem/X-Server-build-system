#!/bin/sh

PKGNAME="m17n-lib"
MINNAME="m17n"

if [[ "${CHECK_PACKAGE_VERSION}" == "true" ]]; then
    # check latest release version
    echo -en "${GREY}Check ${CYAN}${PKGNAME}${GREY} latest release:${CDEF} "
    DOWNLOAD="http://download.savannah.nongnu.org/releases/m17n/"
    VERSION=$(wget -q -O - "${DOWNLOAD}" | grep '<a href="m17n-lib-' | \
        grep '.tar.gz"' | grep -v RC | cut -d \" -f 4 | cut -d - -f 3 | rev | \
        cut -d . -f 3- | rev | sort -V | tail -n 1)
    SOURCE="${PKGNAME}-${VERSION}.tar.gz"
    echo "${VERSION}"

    # download source archive if does not exist
    if ! [ -r "${SOURCE}" ]; then
        echo -e "${YELLOW}Downloading ${SOURCE} source archive${CDEF}"
        wget "${DOWNLOAD}/${SOURCE}"
    fi

    echo -en "${GREY}Check ${CYAN}${MINNAME}-db${GREY} latest release:${CDEF} "
    DBVERSION=$(wget -q -O - "${DOWNLOAD}" | grep '<a href="m17n-db-' | \
        grep '.tar.gz"' | grep -v RC | cut -d \" -f 4 | cut -d - -f 3 | rev | \
        cut -d . -f 3- | rev | sort -V | tail -n 1)
    DBSOURCE="${MINNAME}-db-${VERSION}.tar.gz"
    echo "${VERSION}"

    if ! [ -r "${DBSOURCE}" ]; then
        echo -e "${YELLOW}Downloading ${DBSOURCE} source archive${CDEF}"
        wget "${DOWNLOAD}/${DBSOURCE}"
    fi
else
    SOURCE=$(ls "${PKGNAME}-"*.tar.?z*)
    VERSION=$(echo "${SOURCE}" | rev | cut -d - -f 1 | cut -d . -f 3- | rev)
    DBSOURCE=$(ls "${MINNAME}-db-"*.tar.?z*)
    DBVERSION=$(echo "${DBSOURCE}" | rev | cut -d - -f 1 | cut -d . -f 3- | rev)
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

# compile and install the m17n-lib:
CXXFLAGS="${SLKCFLAGS}" \
CFLAGS="${SLKCFLAGS}" \
./configure \
    --prefix=/usr \
    --libdir=/usr/lib"${LIBDIRSUFFIX}" \
    --localstatedir=/var \
    --sysconfdir=/etc \
    --mandir=/usr/man \
    --without-gui \
    --disable-static \
    --program-prefix= \
    --program-suffix= \
    --build="${ARCH}"-slackware-linux

make "${NUMJOBS}" || make || exit 1
make install-strip DESTDIR="${PKG}" || exit 1

export ADDITIONAL_DIR="/${PKGNAME}"
. "${CWDD}"/additional-scripts/copydocs.sh

# compile and install the m17n-db:
cd "${TMP}" || exit 1
rm -rf "${MINNAME}-db-${DBVERSION}"
tar xvf "${CWD}/${DBSOURCE}"
cd "${MINNAME}-db-${DBVERSION}" || exit 1
. "${CWDD}"/additional-scripts/setperm.sh

CXXFLAGS="${SLKCFLAGS}" \
CFLAGS="${SLKCFLAGS}" \
    ./configure \
    --prefix=/usr \
    --libdir=/usr/lib"${LIBDIRSUFFIX}" \
    --localstatedir=/var \
    --sysconfdir=/etc \
    --program-prefix= \
    --program-suffix= \
    --build="${ARCH}"-slackware-linux

make "${NUMJOBS}" || make || exit 1
make DESTDIR="${PKG}" install || exit 1

export ADDITIONAL_DIR="/${MINNAME}-db"
. "${CWDD}"/additional-scripts/copydocs.sh

. "${CWDD}"/additional-scripts/strip-binaries.sh
. "${CWDD}"/additional-scripts/compressmanpages.sh

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
