#!/bin/bash

SCRIPT="setup.04.${PKGNAME}"
SETUPDIR="${PKG}/var/log/setup"
mkdir -p "${SETUPDIR}"
cp -a "${CWD}/post-install/${PKGNAME}/${SCRIPT}" "${SETUPDIR}/"

chown root:root "${SETUPDIR}/${SCRIPT}"
chmod 755 "${SETUPDIR}/${SCRIPT}"
