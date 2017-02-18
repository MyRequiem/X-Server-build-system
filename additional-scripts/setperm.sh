#!/bin/bash

chown -R root:root .
find . \( \
        -perm 777 -o \
        -perm 775 -o \
        -perm 711 -o \
        -perm 555 -o \
        -perm 511 \
    \) -exec chmod 755 {} \; \
    -o \( \
        -perm 666 -o \
        -perm 664 -o \
        -perm 600 -o \
        -perm 444 -o \
        -perm 440 -o \
        -perm 400 \
    \) -exec chmod 644 {} \;
