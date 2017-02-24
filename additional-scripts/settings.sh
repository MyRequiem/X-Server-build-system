#!/bin/bash

# ============================== Settings ======================================
# temp directory for building packages
export TEMP="/tmp/x-build"
# output for packages
export OUTPUT="/root/src/x-packages"
# package extension
export EXT="txz"
# tar fot package
export TAG="myreq"
# branch mesa package [https://www.mesa3d.org/]
export MESA_BRANCH="13"
# build package only if it is not in OUTPUT
export BUILD_ONLY_NOT_EXIST="true"
# install package after build
export INSTALL_AFTER_BUILD="false"
# check package version
export CHECK_PACKAGE_VERSION="false"
# only download source code (without build)
export ONLY_DOWNLOAD="false"
# ========================== End of settings ===================================

# if ONLY_DOWNLOAD="true" variable CHECK_PACKAGE_VERSION must be set "true"
[[ "${ONLY_DOWNLOAD}" == "true" ]] && export CHECK_PACKAGE_VERSION="true"
