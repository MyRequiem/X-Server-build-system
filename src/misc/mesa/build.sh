#!/bin/sh

PKGNAME="mesa"

if [[ "${CHECK_PACKAGE_VERSION}" == "true" ]]; then
    # check latest release version
    echo -en "${GREY}Check ${CYAN}${PKGNAME}${GREY} latest release:${CDEF} "
    VERSION=$(wget -q -O - https://www.mesa3d.org/ \
        | grep ">Mesa ${MESA_BRANCH}." | grep "is released" | head -n 1 | \
        cut -d " " -f 3 | cut -d "<" -f 1)
    SOURCE="${PKGNAME}-${VERSION}.tar.xz"
    echo "${VERSION}"

    if ! [ -r "${SOURCE}" ]; then
        echo -e "${YELLOW}Download ${SOURCE} source archive${CDEF}"
        wget "https://mesa.freedesktop.org/archive/${VERSION}/${SOURCE}"
    fi
else
    SOURCE=$(ls "${PKGNAME}"-"${MESA_BRANCH}".*.tar.?z*)
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

# let's kill the warning about operating on a dangling symlink:
if [ -f src/gallium/state_trackers/d3d1x/w32api ]; then
    rm -f src/gallium/state_trackers/d3d1x/w32api
fi

# don't worry if Mako is not present:
zcat "${CWD}"/mesa.no.mako.diff.gz | patch -p1 --verbose || exit 1

# fix detection of libLLVM when built with CMake
sed -i 's/LLVM_SO_NAME=.*/LLVM_SO_NAME=LLVM/' configure.ac

# seems to need this to avoid tripping over a different libtool version:
autoreconf -fi

# be sure this list is up-to-date:
DRI_DRIVERS="i915,i965,nouveau,r200,radeon,swrast"
GALLIUM_DRIVERS="nouveau,r300,r600,svga,radeonsi,swrast"
EGL_PLATFORMS="drm,x11"

CFLAGS="${SLKCFLAGS}" \
./configure \
    --prefix=/usr \
    --sysconfdir=/etc \
    --libdir=/usr/lib"${LIBDIRSUFFIX}" \
    --mandir=/usr/man \
    --docdir=/usr/doc/"${PKGNAME}-${VERSION}" \
    --with-dri-driverdir=/usr/lib"${LIBDIRSUFFIX}"/xorg/modules/dri \
    --with-dri-drivers="${DRI_DRIVERS}" \
    --with-gallium-drivers="${GALLIUM_DRIVERS}" \
    --with-egl-platforms="${EGL_PLATFORMS}" \
    --enable-gallium-llvm \
    --enable-llvm-shared-libs \
    --enable-egl \
    --enable-texture-float \
    --enable-shared-glapi \
    --enable-xa \
    --enable-nine \
    --enable-osmesa \
    --enable-dri \
    --enable-dri3 \
    --enable-gbm \
    --enable-glx \
    --enable-glx-tls \
    --enable-gles1 \
    --enable-gles2 \
    --enable-vdpau \
    --build="${ARCH}"-slackware-linux

make "${NUMJOBS}" || make || exit 1
make install DESTDIR="${PKG}" || exit 1

. "${CWDD}"/additional-scripts/strip-binaries.sh
. "${CWDD}"/additional-scripts/copydocs.sh
. "${CWDD}"/additional-scripts/compressmanpages.sh

mkdir -p "${PKG}"/install
cat "${CWD}"/slack-desc > "${PKG}"/install/slack-desc

cd "${PKG}" || exit 1
mkdir -p "${OUTPUT}/misc"
BUILD=$(cat "${CWDD}/build/${PKGNAME}")
PKG="${OUTPUT}/misc/${PKGNAME}-${VERSION}-${ARCH}-${BUILD}_${TAG}.${EXT}"
rm -f "${PKG}"
makepkg -l y -c n "${PKG}"

if [[ "${INSTALL_AFTER_BUILD}" == "true" ]]; then
    upgradepkg --install-new --reinstall "${PKG}"
fi
