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
# docs files
export DOCS="AUTHORS COPYING* INSTALL NEWS README TODO ChangeLog*"
# install package after build (true, false)
export INSTALL_AFTER_BUILD="false"
# only download srt (without build)
export ONLY_DOWNLOAD="false"
