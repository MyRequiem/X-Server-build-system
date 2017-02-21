#!/bin/bash

case "$(uname -m)" in
    i?86)   export ARCH="i586"  ;;
    x86_64) export ARCH="x86_64";;
    *)      echo "Supported architectures: i586 or x86_64"; exit 1;;
esac

if [[ "${ARCH}" == "x86_64" ]]; then
    export LIBDIRSUFFIX="64"
    export SLKCFLAGS="-O2 -fPIC"
else
    export LIBDIRSUFFIX=""
    export SLKCFLAGS="-O2 -march=i586 -mtune=i686"
fi

export NUMJOBS=" -j7 "
export CWDD=$(pwd)
