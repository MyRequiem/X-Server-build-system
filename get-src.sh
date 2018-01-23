#!/bin/bash

# copy all needed sources from Slackware source tree to ./src

SCRIPT_NAME="$(basename "$0")"
SRC_PATH="$1"

usage() {
    echo "Usage: ./${SCRIPT_NAME} /path/to/root/of/Slackware/src/tree"
    echo "Example:"
    echo -e "$ ./${SCRIPT_NAME} /mnt/src/source/"
    exit 1
}

error() {
    if [[ "x$1" == "xtree_fail" ]]; then
        echo "Not the right path to the Slackware tree"
    else
        echo "${SCRIPT_NAME} not found in $(pwd)"
    fi

    exit 1
}

[[ "x${SRC_PATH}" == "x" ]] && usage
! [[ -d "${SRC_PATH}" && -d "${SRC_PATH}/x" ]] && error tree_fail
! [ -f "./${SCRIPT_NAME}" ] && error exec_path_fail

# remove last slash from path to Slackware tree
SRC_PATH="${SRC_PATH/%\//}"/x

# CWD="$(pwd)/src"
PACKAGES="$(/bin/grep '^[a-z]' queue)"
for PACKAGE in ${PACKAGES}; do
    GROUP="$(echo "${PACKAGE}" | cut -d : -f 1)"
    PKGNAME="$(echo "${PACKAGE}" | cut -d : -f 2)"

    # 11-skel package does not have source archive
    [ "x${PKGNAME}" ==  "xx11-skel" ] && continue

    SOURCE="$(find "${SRC_PATH}" -type f \
        -name "${PKGNAME}-[0-9]*.tar.?z*" -a \
        ! -name "*.sig")"

    COPY_PATH="./src/${GROUP}"
    [ "x${GROUP}" == "xmisc"  ] && COPY_PATH="${COPY_PATH}/${PKGNAME}"

    cp -v "${SOURCE}" "${COPY_PATH}"
    # package m17n-lib has two source archive
    [ "x${PKGNAME}" == "xm17n-lib"  ] && \
        find "${SRC_PATH}" -type f \
            -name "m17n-db-[0-9]*.tar.?z*" -a \
            ! -name "*.sig" -exec cp -v {} "${COPY_PATH}" \;
done
