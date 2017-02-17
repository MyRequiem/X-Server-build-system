#!/bin/sh

PKGNAME="libvdpau"

if [[ "${CHECK_PACKAGE_VERSION}" == "true" ]]; then
    # check latest release version
    echo -en "${GREY}Check ${PKGNAME} latest release:${CDEF} "
    VERSION=$(wget -q -O - https://cgit.freedesktop.org/~aplattner/libvdpau | \
        grep -A 1 Download | tail -n 1 | cut -d / -f 5 | rev | cut -d - -f 1 | \
        rev | cut -d "<" -f 1)
    SOURCE="${PKGNAME}-${VERSION}.tar.xz"
    echo "${VERSION}"

    if ! [ -r "${SOURCE}" ]; then
        echo -e "${YELLOW}Clone and creating ${SOURCE} source archive${CDEF}"
        git clone git://people.freedesktop.org/~aplattner/libvdpau
        mv "${PKGNAME}" "${PKGNAME}-${VERSION}"
        tar cJvf "${SOURCE}" "${PKGNAME}-${VERSION}"
        rm -rf "${PKGNAME}-${VERSION}"
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

if ! [ -x ./configure ]; then
    ./autogen.sh
fi

CFLAGS="${SLKCFLAGS}" \
CXXFLAGS="${SLKCFLAGS}" \
./configure \
  --prefix=/usr \
  --libdir=/usr/lib"${LIBDIRSUFFIX}" \
  --sysconfdir=/etc \
  --localstatedir=/var \
  --mandir=/usr/man \
  --docdir=/usr/doc/"${PKGNAME}-${VERSION}" \
  --disable-static \
  --build="${ARCH}"-slackware-linux

make "${NUMJOBS}" || make || exit 1
make install-strip DESTDIR="${PKG}" || exit 1

mkdir -p "${PKG}"/etc/profile.d
cp -a "${CWD}"/profile.d/vdpau.sh "${PKG}"/etc/profile.d/vdpau.sh.new
cp -a "${CWD}"/profile.d/vdpau.csh "${PKG}"/etc/profile.d/vdpau.csh.new
chown root:root "${PKG}"/etc/profile.d/*
chmod 755 "${PKG}"/etc/profile.d/*

. "${CWDD}"/strip-binaries.sh

# don't clobber the config file on upgrades
mv "${PKG}"/etc/vdpau_wrapper.cfg "${PKG}"/etc/vdpau_wrapper.cfg.new

DOCDIR="${PKG}/usr/doc/${PKGNAME}-${VERSION}"
mkdir -p "${DOCDIR}"
for DOC in ${DOCS}; do
    if [ -r "${DOC}" ]; then
        cp "${DOC}" "${DOCDIR}"
    fi
done

mkdir -p "${PKG}"/install
cat "${CWD}"/slack-desc > "${PKG}"/install/slack-desc
cat "${CWD}"/doinst.sh > "${PKG}"/install/doinst.sh

cd "${PKG}" || exit 1
mkdir -p "${OUTPUT}/misc"
BUILD=$(cat "${CWDD}/build/${PKGNAME}")
PKG="${OUTPUT}/misc/${PKGNAME}-${VERSION}-${ARCH}-${BUILD}_${TAG}.${EXT}"
rm -f "${PKG}"
makepkg -l y -c n "${PKG}"

if [[ "${INSTALL_AFTER_BUILD}" == "true" ]]; then
    upgradepkg --install-new --reinstall "${PKG}"
fi
