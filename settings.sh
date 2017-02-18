#!/bin/bash

# temp directory for building packages
export TMP="/tmp/x-build"
# output for packages
export OUTPUT="/root/src/x-packages"
# package extension
export EXT="txz"
# tar fot package
export TAG="myreq"
# number of assembly flows
export NUMJOBS=" -j7 "
# install package after build (true, false)
export INSTALL_AFTER_BUILD="false"
# check package version
export CHECK_PACKAGE_VERSION="false"
# only download src (without build)
export ONLY_DOWNLOAD="false"
