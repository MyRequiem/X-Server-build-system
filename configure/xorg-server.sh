#!/bin/bash

DEFAULTFONTPATH=""
FONTDIRS="TTF 100dpi Type1 cyrillic 75dpi misc Speedo"
for FONTDIR in ${FONTDIRS}; do
    [[ "x${DEFAULTFONTPATH}" != "x" ]] && DEFAULTFONTPATH="${DEFAULTFONTPATH},"
    DEFAULTFONTPATH="${DEFAULTFONTPATH}/usr/share/fonts/${FONTDIR}"
done

autoreconf -vif

CFLAGS="${SLKCFLAGS}" \
./configure \
    --prefix=/usr \
    --libdir=/usr/lib"${LIBDIRSUFFIX}" \
    --sysconfdir=/etc \
    --localstatedir=/var \
    --infodir=/usr/info \
    --mandir=/usr/man \
    --with-pic \
    --with-int10=x86emu \
    --with-default-font-path="${DEFAULTFONTPATH}" \
    --with-module-dir=/usr/lib"${LIBDIRSUFFIX}"/xorg/modules \
    --with-os-name="Slackware" \
    --with-os-vendor="Slackware Linux Project" \
    --with-xkb-path=/etc/X11/xkb \
    --with-xkb-output=/var/lib/xkb \
    --enable-xorg \
    --enable-dri \
    --enable-dri2 \
    --enable-xfbdev \
    --enable-kdrive-kbd \
    --enable-kdrive-evdev \
    --enable-kdrive-mouse \
    --enable-config-udev \
    --enable-suid-wrapper \
    --disable-static \
    --disable-config-hal \
    --disable-dri3 \
    --disable-xnest \
    --disable-xephyr \
    --disable-systemd-logind \
    --disable-config-udev-kms \
    --disable-aiglx \
    --disable-screensaver \
    --disable-xvmc \
    --disable-xdmcp \
    --disable-xdm-auth-1 \
    --disable-xace \
    --disable-config-wscons \
    --disable-linux-acpi \
    --disable-linux-apm \
    --disable-xquartz \
    --disable-xwayland \
    --disable-xfake \
    --disable-ipv6 \
    --disable-xvfb \
    --disable-glamor \
    --disable-xwin \
    --disable-kdrive \
    --disable-listen-tcp \
    --disable-record \
    --disable-unit-tests \
    --disable-libunwind \
    --disable-xtrans-send-fds \
    --build="${ARCH}"-slackware-linux

# to prevent the error "No rule to make target '-ldl'" on 86_64 machine
if [[ "${ARCH}" == "x86_64" && -r hw/xfree86/Makefile ]]; then
    sed -i -e 's#-ldl##' hw/xfree86/Makefile
    sed -i -e 's#-lm#-lm -ldl#' hw/xfree86/Makefile
fi
