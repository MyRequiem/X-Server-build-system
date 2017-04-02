#!/bin/bash

# ============================== Settings ======================================
# temp directory for building packages
TEMP="/tmp/x-build"
# output for packages
OUTPUT="/root/src/x-packages"
# package extension
EXT="txz"
# tag for package
TAG="myreq"
# build package only if it is not in OUTPUT
BUILD_ONLY_NOT_EXIST="true"
# install package after build
INSTALL_AFTER_BUILD="false"
# check package version
CHECK_PACKAGE_VERSION="true"
# only download source code (without build)
ONLY_DOWNLOAD="true"
# ========================== End of settings ===================================


# if ONLY_DOWNLOAD == "true" variable CHECK_PACKAGE_VERSION must be set "true"
# and BUILD_ONLY_NOT_EXIST must be set "false"
[[ "${ONLY_DOWNLOAD}" == "true" ]] && CHECK_PACKAGE_VERSION="true" &&
    BUILD_ONLY_NOT_EXIST="false"

export TEMP
export OUTPUT
export EXT
export TAG
export BUILD_ONLY_NOT_EXIST
export INSTALL_AFTER_BUILD
export CHECK_PACKAGE_VERSION
export ONLY_DOWNLOAD
