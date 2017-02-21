#!/bin/bash

# temp directory for building packages
export TMP="/tmp/x-build"
# output for packages
export OUTPUT="/root/src/x-packages"
# package extension
export EXT="txz"
# tar fot package
export TAG="myreq"
# install package after build (true, false)
export INSTALL_AFTER_BUILD="false"
# check package version
export CHECK_PACKAGE_VERSION="true"
# only download src (without build)
export ONLY_DOWNLOAD="false"

# if ONLY_DOWNLOAD="true" variable CHECK_PACKAGE_VERSION must be set "true"
[[ "${ONLY_DOWNLOAD}" == "true" ]] && export CHECK_PACKAGE_VERSION="true"
