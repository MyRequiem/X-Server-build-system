#!/bin/sh

PKGNAME="fontconfig"

if [[ "${CHECK_PACKAGE_VERSION}" == "true" ]]; then
    # check latest release version
    echo -en "${GREY}Check ${CYAN}${PKGNAME}${GREY} latest release:${CDEF} "
    URL="https://www.freedesktop.org/software/fontconfig/release/"
    VERSION=$(wget -q -O - "${URL}" | grep "<a href=" | grep "${PKGNAME}" | \
        grep tar.bz2 | cut -d \" -f 8 | rev | cut -d - -f 1 | cut -d . -f 3- | \
        rev | sort -V | tail -n 1)
    SOURCE="${PKGNAME}-${VERSION}.tar.bz2"
    echo "${VERSION}"

    # download source archive if does not exist
    if ! [ -r "${SOURCE}" ]; then
        echo -e "${YELLOW}Downloading ${SOURCE} source archive${CDEF}"
        wget "${URL}${SOURCE}"
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

zcat "${CWD}/patches/dejavu.diff.gz" | patch -p1 --verbose || exit 1
zcat "${CWD}/patches/font.dir.list.diff.gz" | patch -p1 --verbose || exit 1

CFLAGS="${SLKCFLAGS}" \
./configure \
    --prefix=/usr \
    --libdir=/usr/lib"${LIBDIRSUFFIX}" \
    --mandir=/usr/man \
    --sysconfdir=/etc \
    --with-templatedir=/etc/fonts/conf.avail \
    --with-baseconfigdir=/etc/fonts \
    --with-configdir=/etc/fonts/conf.d \
    --with-xmldir=/etc/fonts \
    --localstatedir=/var \
    --enable-static=no \
    --build="${ARCH}"-slackware-linux

make "${NUMJOBS}" || make || exit 1
make install DESTDIR="${PKG}" || exit 1

SHAREFONTCONFIG="${PKG}/usr/share/fontconfig"
mkdir -p "${SHAREFONTCONFIG}"
(
    cd "${SHAREFONTCONFIG}" || exit 1
    ln -sf /etc/fonts/conf.avail conf.avail
)

. "${CWDD}"/additional-scripts/strip-binaries.sh
. "${CWDD}"/additional-scripts/copydocs.sh
. "${CWDD}"/additional-scripts/compressmanpages.sh

# remove extra documentation
DOCDIR="${PKG}/usr/doc/${PKGNAME}-${VERSION}"
TXT="${DOCDIR}/${PKGNAME}/${PKGNAME}-user.txt"
if [ -f "${TXT}" ]; then
    mv "${TXT}" "${DOCDIR}"
    rm -rf "${PKG}/usr/doc/${PKGNAME}-${VERSION}/${PKGNAME}"
fi

mkdir -p "${PKG}/var/log/setup"
cat "${CWD}/setup.05.fontconfig" > "${PKG}/var/log/setup/setup.05.fontconfig"
chmod 755 "${PKG}/var/log/setup/setup.05.fontconfig"

# Set up the default options in /etc/fonts/conf.d:
CONFD="${PKG}/etc/fonts/conf.d"
(
    cd "${CONFD}" || exit 1
    for FONTCONF in \
            20-unhint-small-vera.conf \
            30-urw-aliases.conf \
            30-metric-aliases.conf \
            40-nonlatin.conf \
            45-latin.conf \
            49-sansserif.conf \
            50-user.conf \
            51-local.conf \
            60-latin.conf \
            65-fonts-persian.conf \
            65-nonlatin.conf \
            69-unifont.conf \
            80-delicious.conf \
            90-synthetic.conf; do
        if [ -r "../conf.avail/${FONTCONF}" ]; then
            ln -sf ../conf.avail/"${FONTCONF}" "${FONTCONF}"
        else
            echo "ERROR: unable to symlink ../conf.avail/${FONTCONF}"
            echo "File does not exist."
            exit 1
        fi
    done
)

# remove broken links in "${PKG}/etc/fonts/conf.d" if any
cd "${CONFD}" || exit 1
LINKS=$(find . -type l)
for LINK in ${LINKS}; do
    if ! [ -e "$(readlink "${LINK}")" ]; then
        rm -f "${LINK}"
    fi
done

mkdir -p "${PKG}/install"
cat "${CWD}/slack-desc" > "${PKG}/install/slack-desc"
cat "${CWD}/doinst.sh" > "${PKG}/install/doinst.sh"

cd "${PKG}" || exit 1
mkdir -p "${OUTPUT}/misc"
BUILD=$(cat "${CWDD}/build/${PKGNAME}" 2>/dev/null || echo "1")
PKG="${OUTPUT}/misc/${PKGNAME}-${VERSION}-${ARCH}-${BUILD}${TAG}.${EXT}"
rm -f "${PKG}"
makepkg -l y -c n "${PKG}"

if [[ "${INSTALL_AFTER_BUILD}" == "true" ]]; then
    upgradepkg --install-new --reinstall "${PKG}"
fi
