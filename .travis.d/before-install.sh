#!/bin/bash

if [[ "$TRAVIS_OS_NAME" == "Linux" ]]; then
    sudo apt-get install -y wget \
       clang-3.6 libc6-dev make git libicu52 libicu-dev \
       git autoconf libtool pkg-config \
       libblocksruntime-dev \
       libkqueue-dev \
       libpthread-workqueue-dev \
       systemtap-sdt-dev \
       libbsd-dev libbsd0 libbsd0-dbg \
       curl libcurl4-openssl-dev \
       libedit-dev \
       python2.7 python2.7-dev \
       libxml2

    sudo update-alternatives --quiet --install /usr/bin/clang clang /usr/bin/clang-3.6 100
    sudo update-alternatives --quiet --install /usr/bin/clang++ clang++ /usr/bin/clang++-3.6 100
fi
