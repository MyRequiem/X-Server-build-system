#!/bin/bash

# strip binaries:
echo -e "${GREEN}Strip binaries in ${BROWN}${PKG}/${CDEF}"

find "${PKG}" -print0 | xargs -0 file | grep "executable" | grep ELF | \
    cut -f 1 -d : | xargs strip --strip-unneeded 2> /dev/null
find "${PKG}" -print0 | xargs -0 file | grep "shared object" | grep ELF | \
    cut -f 1 -d : | xargs strip --strip-unneeded 2> /dev/null
find "${PKG}" -print0 | xargs -0 file | grep "current ar archive" | grep ELF | \
    cut -f 1 -d : | xargs strip -g 2> /dev/null
