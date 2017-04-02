#!/bin/bash

LANG=en_EN.UTF-8
:>PACKAGES.TXT
echo -e "PACKAGES.TXT;  $(date -u)\n" > PACKAGES.TXT

for PACKAGE in $(find slack-desc/ | cut -d / -f 2 | sort); do
    PKGINSTALL="$(find /var/log/packages/ -type f -name "${PACKAGE}-[0-9]*" | \
        rev | cut -d / -f 1 | rev)"
    {
        echo "PACKAGE NAME:  ${PKGINSTALL}"
        echo -n "-----------------------------------------------------------"
        echo "---------------------"
        grep "${PACKAGE}:" "slack-desc/${PACKAGE}"
        echo "" >> PACKAGES.TXT
    } >> PACKAGES.TXT
done
