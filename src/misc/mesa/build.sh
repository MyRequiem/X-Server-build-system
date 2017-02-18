#!/bin/sh

PKGNAME="mesa"
DEMOS="demos"

if [[ "${CHECK_PACKAGE_VERSION}" == "true" ]]; then
    # check latest release version
    echo -en "${GREY}Check ${PKGNAME} latest release:${CDEF} "
    VERSION=$(wget -q -O - https://www.mesa3d.org/ | grep ">Mesa" | \
        grep "is released" | head -n 1 | cut -d " " -f 3 | cut -d "<" -f 1)
    SOURCE="${PKGNAME}-${VERSION}.tar.xz"
    echo "${VERSION}"

    DOWNLOAD="https://mesa.freedesktop.org/archive"
    if ! [ -r "${SOURCE}" ]; then
        echo -e "${YELLOW}Download ${SOURCE} source archive${CDEF}"
        wget "${DOWNLOAD}/${VERSION}/${SOURCE}"
    fi

    # building mesa package require mesa-demos source
    echo -en "${GREY}Check "${PKGNAME}-${DEMOS}" latest release:${CDEF} "
    DEMOSVERSION=$(wget -q -O - https://www.mesa3d.org/ | grep "${DEMOS}" | \
        grep released | head -n 1 | cut -d " " -f 3)
    DEMOSSOURCE="${PKGNAME}-${DEMOS}-${DEMOSVERSION}.tar.gz"
    echo "${DEMOSVERSION}"

    if ! [ -r "${DEMOSSOURCE}" ]; then
        echo -e "${YELLOW}Download ${PKGNAME}-${DEMOS} source archive${CDEF}"
        wget "${DOWNLOAD}/${DEMOS}/${DEMOSVERSION}/${DEMOSSOURCE}"
    fi
else
    SOURCE=$(ls "${PKGNAME}"-[0-9]*.tar.?z*)
    VERSION=$(echo "${SOURCE}" | rev | cut -d - -f 1 | cut -d . -f 3- | rev)
    DEMOSSOURCE=$(ls "${PKGNAME}-${DEMOS}"*.tar.?z*)
    DEMOSVERSION=$(echo "${DEMOSSOURCE}" | rev | cut -d - -f 1 | \
        cut -d . -f 3- | rev)
fi

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

# now build and install the demos
(
    cd "${TMP}" || exit 1
    rm -rf "${PKGNAME}-${DEMOS}-${DEMOSVERSION}"
    tar xvf "${CWD}/${DEMOSSOURCE}" || exit 1
    cd "${PKGNAME}-${DEMOS}-${DEMOSVERSION}" || exit 1
    . "${CWDD}"/setperm.sh

    CFLAGS="${SLKCFLAGS}" \
    ./configure \
        --prefix=/usr \
        --build="${ARCH}"-slackware-linux

    # build and install gears and glinfo, as well as a few other demos
    BIN="${PKG}"/usr/bin
    mkdir -p "$BIN"
    make -C src/demos gears glinfo
    cp -a src/demos/{gears,glinfo} "${BIN}"

    XDEMOS="glthreads glxcontexts glxdemo glxgears glxgears_fbconfig \
        glxheads glxinfo glxpbdemo glxpixmap"
    for XDEMO in ${XDEMOS}; do
        if [ -r "src/xdemos/${XDEMO}.c" ]; then
            make -C src/xdemos "${XDEMO}"
            cp -a src/xdemos/"${XDEMO}" "${BIN}"
        fi
    done
)

. "${CWDD}"/strip-binaries.sh
. "${CWDD}"/copydocs.sh
. "${CWDD}"/compressmanpages.sh

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
