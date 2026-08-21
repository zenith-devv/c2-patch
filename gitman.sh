#!/usr/bin/env bash

NAME="c2-patch"
VERSION=""

DEPENDS_PORTAGE=()
DEPENDS_PACMAN=()
DEPENDS_APT=()
DEPENDS_DNF=()
DEPENDS_ZYPPER=()
DEPENDS_APK=()
DEPENDS_XBPS=()
DEPENDS_PKG=()

prepare() {
    :
}

build() {
    :
}

check() {
    :
}

install() {
    cd setup
    ./linux-jdk17-temurin-installer.sh
}
