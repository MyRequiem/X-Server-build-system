#!/bin/bash

PATCHDIR="${CWD}/patches/${PKGNAME}"
DIFFS=$(find "${PATCHDIR}" -type f -name "*.diff.gz")
for DIFF in ${DIFFS}; do
    echo -e "\n${BROWN}Applying patch: $(basename "${DIFF}")${CDEF}"
    zcat "${DIFF}" | patch -p1 --verbose || exit 1
done
