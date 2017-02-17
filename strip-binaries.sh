#!/bin/bash

# strip binaries:
echo -e "${GREEN}Strip binaries in ${BROWN}${PKG}/${CDEF}"
find "${PKG}" -print0 | xargs -0 file | \
    grep -e "executable" -e "shared object" | \
    grep ELF | cut -f 1 -d : | xargs strip --strip-unneeded 2> /dev/null
