#!/bin/bash

# ============================== Settings ======================================
# temp directory for building packages
export TEMP="/tmp/x-build"
# output for packages
export OUTPUT="/tmp/x-packages"
# package extension
export EXT="txz"
# tag for package
export TAG="myreq"
# branch mesa package [https://www.mesa3d.org/]
export MESA_BRANCH="13"
# build package only if it is not in OUTPUT
export BUILD_ONLY_NOT_EXIST="false"
# install package after build
export INSTALL_AFTER_BUILD="true"
# check package version
export CHECK_PACKAGE_VERSION="true"
# only download source code (without build)
export ONLY_DOWNLOAD="false"
# ========================== End of settings ===================================

# if ONLY_DOWNLOAD == "true" variable CHECK_PACKAGE_VERSION must be set "true"
# and BUILD_ONLY_NOT_EXIST must be set "false"
[[ "${ONLY_DOWNLOAD}" == "true" ]] && export CHECK_PACKAGE_VERSION="true" &&
    BUILD_ONLY_NOT_EXIST="false"
