#!/bin/bash

find "${PKG}" -type f -print0 | xargs -0 file 2>/dev/null | \
    grep -e "executable" -e "shared object" | grep ELF | cut -f 1 -d : | \
    xargs strip --strip-unneeded 2>/dev/null

find "${PKG}" -type f -print0 | xargs -0 file 2>/dev/null | \
    grep "current ar archive" | grep ELF | cut -f 1 -d : | \
    xargs strip -g 2>/dev/null
