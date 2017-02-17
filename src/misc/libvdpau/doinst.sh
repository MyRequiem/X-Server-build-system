#!/bin/bash

config() {
    NEW="$1"
    OLD="$(dirname "${NEW}")/$(basename "${NEW}" .new)"
    if ! [ -r "${OLD}" ]; then
        mv "${NEW}" "${OLD}"
    else
        MD5OLD=$(md5sum "${OLD}" | cut -d " " -f 1)
        MD5NEW=$(md5sum "${NEW}" | cut -d " " -f 1)
        if [[ "${MD5OLD}" == "${MD5NEW}" ]]; then
            rm "${NEW}"
        fi
    fi
}

config etc/vdpau_wrapper.cfg.new
config etc/profile.d/vdpau.sh.new
config etc/profile.d/vdpau.csh.new

