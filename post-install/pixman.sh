#!/bin/bash

(
    cd "${PKG}/usr/include" || exit 1
    ln -sf pixman-1/pixman-version.h pixman-version.h
    ln -sf pixman-1/pixman.h pixman.h
    ln -sf pixman-1 pixman
)
