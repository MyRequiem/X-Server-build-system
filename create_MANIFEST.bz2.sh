#!/bin/bash

PKGDIR="$1"

if [[ "x${PKGDIR}" == "x" ]]; then
    echo -e "Usage:\nsh $(basename "$0")" path_to_dir_with_x_packages
    exit 1
fi

if ! [ -d "${PKGDIR}" ]; then
    echo "Directory ${PKGDIR} not found"
    exit 1
fi

rm -f MANIFEST.bz2
:>MANIFEST
PKGS="$(find "${PKGDIR}" -type f -name "*.t?z" | sort)"
for PKG in ${PKGS}; do
    {
        echo -n "++=================================================="
        echo -en "============================\n||\n||   Package:  "
        FILENAME="$(basename "${PKG}")"
        PKGNAME="$(echo "${FILENAME}" | rev | cut -d - -f 4- | rev)"
        MODULE="$(/bin/grep -E ":${PKGNAME}$" queue | cut -d : -f 1)"
        echo -e "${MODULE}/${FILENAME}\n||"
        echo -n "++=================================================="
        echo "============================"
        tar -tvf "${PKG}"
        echo -e "\n"
    } >> MANIFEST
done

bzip2 -vc9 MANIFEST > MANIFEST.bz2
rm -f MANIFEST
