#!/bin/sh

PRGNAM=freeglut

# check latest release version
echo -en "\033[0;37mCheck FreeGLUT latest release:\033[0m "
LATESTRELEASELINK=$(wget -q -O - http://freeglut.sourceforge.net/ | \
    grep -A 2 "Stable Releases" | tail -n 1 | cut -d \" -f 2 | cut -d \? -f 1)
SOURCE=$(echo "${LATESTRELEASELINK}" | rev | cut -d / -f 1 | rev)
VERSION=$(echo "${SOURCE}" | cut -d - -f 2 | rev | cut -d . -f 3- | rev)
echo "${VERSION}"

# download source archive if does not exist
if ! [ -r "${SOURCE}" ]; then
    # delete old source archive if exist
    rm -f ${PRGNAM}-*.tar.?z*
    echo -e "\033[1;33mDownloading ${SOURCE} source archive\033[0m:"
    wget "${LATESTRELEASELINK}"
fi

[[ "${ONLY_DOWNLOAD}" == "true" ]] && exit 0

CWD=$(pwd)
PKG=${TMP}/package-$PRGNAM

rm -rf "${PKG}"
mkdir -p "${PKG}"
cd "${TMP}" || exit 1
rm -rf "${PRGNAM}-${VERSION}"
tar xvf "${CWD}/${SOURCE}" || exit 1
cd "${PRGNAM}-${VERSION}" || exit 1
. "${CWDD}"/setperm.sh

mkdir build
cd build || exit 1
cmake \
    -DCMAKE_C_FLAGS:STRING="${SLKCFLAGS}" \
    -DCMAKE_C_FLAGS_RELEASE:STRING="${SLKCFLAGS}" \
    -DCMAKE_CXX_FLAGS:STRING="${SLKCFLAGS}" \
    -DCMAKE_CXX_FLAGS_RELEASE:STRING="${SLKCFLAGS}" \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=/usr \
    -DMAN_INSTALL_DIR=/usr/man \
    -DSYSCONF_INSTALL_DIR=/etc \
    -DLIB_SUFFIX="${LIBDIRSUFFIX}" \
    ..

make "${NUMJOBS}" || make || exit 1
make install DESTDIR="${PKG}"
cd ..

find "${PKG}" -print0 | xargs -0 file | \
    grep -e "executable" -e "shared object" | \
    grep ELF | cut -f 1 -d : | xargs strip --strip-unneeded 2> /dev/null || true

DOCDIR="${PKG}/usr/doc/${PRGNAM}-${VERSION}"
mkdir -p "${DOCDIR}/html"
for DOC in ${DOCS}; do
    if [ -r "${DOC}" ]; then
        cp "${DOC}" "${DOCDIR}"
    fi
done

cp -a doc/*.{html,png} "${DOCDIR}/html"
find "${DOCDIR}" -type f -exec chmod 644 {} \;

mkdir -p "${PKG}/install"
cat "${CWD}/slack-desc" > "${PKG}/install/slack-desc"

cd "${PKG}" || exit 1
mkdir -p "${OUTPUT}/misc"
BUILD=$(cat "${CWDD}/build/${PRGNAM}")
PKG="${OUTPUT}/misc/${PRGNAM}-${VERSION}-${ARCH}-${BUILD}_${TAG}.${EXT}"
rm -f "${PKG}"
makepkg -l y -c n "${PKG}"

if [[ "${INSTALL_AFTER_BUILD}" == "true" ]]; then
    upgradepkg --install-new --reinstall "${PKG}"
fi
