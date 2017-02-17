#!/bin/sh





# PKGNAM=mesa
# VERSION=${VERSION:-11.2.2}
# DEMOVERS=${DEMOVERS:-8.3.0}
# BUILD=${BUILD:-1}
#
# NUMJOBS=${NUMJOBS:--j7}
#
# # Be sure this list is up-to-date:
# DRI_DRIVERS="i915,i965,nouveau,r200,radeon,swrast"
# GALLIUM_DRIVERS="nouveau,r300,r600,svga,radeonsi,swrast"
# EGL_PLATFORMS="drm,x11"
#
# if [ -z "$ARCH" ]; then
#   case "$( uname -m )" in
#     i?86) export ARCH=i586 ;;
#     arm*) export ARCH=arm ;;
#        *) export ARCH=$( uname -m ) ;;
#   esac
# fi
#
# CWD=$(pwd)
# TMP=${TMP:-/tmp}
# PKG=$TMP/package-mesa
#
# if [ "$ARCH" = "i586" ]; then
#   SLKCFLAGS="-O2 -march=i586 -mtune=i686"
#   LIBDIRSUFFIX=""
# elif [ "$ARCH" = "x86_64" ]; then
#   SLKCFLAGS="-O2 -fPIC"
#   LIBDIRSUFFIX="64"
# else
#   SLKCFLAGS="-O2"
#   LIBDIRSUFFIX=""
# fi
#
# rm -rf $PKG
# mkdir -p $TMP $PKG
# cd $TMP
# rm -rf ${PKGNAM}-${VERSION}
#
# tar xvf $CWD/${PKGNAM}-${VERSION}.tar.xz || exit 1
# cd ${PKGNAM}-$VERSION
#
# # Let's kill the warning about operating on a dangling symlink:
# rm -f src/gallium/state_trackers/d3d1x/w32api
#
# # Make sure ownerships and permissions are sane:
# chown -R root:root .
# find . \
#   \( -perm 777 -o -perm 775 -o -perm 711 -o -perm 555 -o -perm 511 \) \
#   -exec chmod 755 {} \; -o \
#   \( -perm 666 -o -perm 664 -o -perm 600 -o -perm 444 -o -perm 440 -o -perm 400 \) \
#   -exec chmod 644 {} \;
#
# # Apply patches from git (and maybe elsewhere):
# # Patches obtained by:
# #   git checkout origin/11.2
# #   git format-patch 5de088f7da75cc0209ff1602ed70aff14f733e4b # 11.2.2 release
# if /bin/ls $CWD/patches/*.patch 1> /dev/null 2> /dev/null ; then
#   for patch in $CWD/patches/*.patch ; do
#     patch -p1 < $patch || exit 1 ;
#   done
# fi
#
# # Don't worry if Mako is not present:
# #sed -i "s,AX_CHECK_PYTHON_MAKO_MODULE(\$PYTHON_MAKO_REQUIRED),,g" configure.ac
# zcat $CWD/mesa.no.mako.diff.gz | patch -p1 --verbose || exit 1
#
# # This doesn't fully do the trick.  See below.  ;-)
# #./autogen.sh
#
# # Fix detection of libLLVM when built with CMake
# sed -i 's/LLVM_SO_NAME=.*/LLVM_SO_NAME=LLVM/' configure.ac
#
# # Seems to need this to avoid tripping over a different libtool version:
# autoreconf -fi
#
# CFLAGS="$SLKCFLAGS" \
# ./configure \
#   --prefix=/usr \
#   --sysconfdir=/etc \
#   --libdir=/usr/lib${LIBDIRSUFFIX} \
#   --mandir=/usr/man \
#   --docdir=/usr/doc/${PKGNAM}-$VERSION \
#   --with-dri-driverdir=/usr/lib${LIBDIRSUFFIX}/xorg/modules/dri \
#   --with-dri-drivers="$DRI_DRIVERS" \
#   --with-gallium-drivers="$GALLIUM_DRIVERS" \
#   --with-egl-platforms="$EGL_PLATFORMS" \
#   --enable-gallium-llvm \
#   --enable-llvm-shared-libs \
#   --enable-egl \
#   --enable-texture-float \
#   --enable-shared-glapi \
#   --enable-xa \
#   --enable-nine \
#   --enable-osmesa \
#   --enable-dri \
#   --enable-dri3 \
#   --enable-gbm \
#   --enable-glx \
#   --enable-glx-tls \
#   --enable-gles1 \
#   --enable-gles2 \
#   --enable-vdpau \
#   --build=$ARCH-slackware-linux
#
# # This is autodetected anyway:
# #  --enable-va \
#
# make $NUMJOBS || make || exit 1
# make install DESTDIR=$PKG || exit 1
#
# # Now install the demos
# ( cd $TMP
#   rm -rf mesa-demos-$DEMOVERS
#   tar xvf $CWD/mesa-demos-$DEMOVERS.tar.?z* || exit 1
#   cd mesa-demos-$DEMOVERS
#   chown -R root:root .
#   find . \
#     \( -perm 777 -o -perm 775 -o -perm 711 -o -perm 555 -o -perm 511 \) \
#     -exec chmod 755 {} \; -o \
#     \( -perm 666 -o -perm 664 -o -perm 600 -o -perm 444 -o -perm 440 -o -perm 400 \) \
#     -exec chmod 644 {} \;
#   CFLAGS="$SLKCFLAGS" \
#   ./configure \
#     --prefix=/usr \
#     --build=$ARCH-slackware-linux
#   # Build and install gears and glinfo, as well as a few other demos
#   make -C src/demos gears glinfo
#   make -C src/xdemos \
#     glthreads glxcontexts glxdemo glxgears glxgears_fbconfig \
#     glxheads glxinfo glxpbdemo glxpixmap
#   mkdir -p $PKG/usr/bin
#   cp -a src/demos/{gears,glinfo} $PKG/usr/bin
#   for i in glthreads glxcontexts glxdemo glxgears glxgears_fbconfig \
#       glxheads glxinfo glxpbdemo glxpixmap ; do
#         cp -a src/xdemos/$i $PKG/usr/bin ;
#   done
# )
#
# # Strip binaries:
# find $PKG | xargs file | grep -e "executable" -e "shared object" | grep ELF \
#   | cut -f 1 -d : | xargs strip --strip-unneeded 2> /dev/null
#
# find $PKG/usr/man -type f -exec gzip -9 {} \;
# for i in $( find $PKG/usr/man -type l ) ; do ln -s $( readlink $i ).gz $i.gz ; rm $i ; done
#
# # Compress info files, if any:
# if [ -d $PKG/usr/info ]; then
#   rm -f $PKG/usr/info/dir
#   gzip -9 $PKG/usr/info/*
# fi
#
# mkdir -p $PKG/usr/doc/$PKGNAM-$VERSION/html
# cp -a \
#   docs/COPYING* docs/relnotes/relnotes-${VERSION}*.html docs/README* docs/GL* \
#   $PKG/usr/doc/$PKGNAM-$VERSION
# cp -a docs/*.html $PKG/usr/doc/$PKGNAM-$VERSION/html
# rm -f $PKG/usr/doc/$PKGNAM-$VERSION/html/relnotes*.html
#
# mkdir -p $PKG/install
# cat $CWD/slack-desc > $PKG/install/slack-desc
#
# cd $PKG
# /sbin/makepkg -l y -c n $TMP/${PKGNAM}-$VERSION-$ARCH-$BUILD.txz
