#!/bin/bash

#Prepare env
sudo apt-get update
sudo apt-get upgrade

sudo apt-get -y install build-essential asciidoc binutils bzip2 gawk gettext git libncurses5-dev \
 patch python3 python2.7 unzip zlib1g-dev lib32gcc-s1 libc6-dev-i386 subversion flex uglifyjs \
 gcc-multilib g++-multilib p7zip p7zip-full msmtp libssl-dev texinfo libglib2.0-dev xmlto \
 qemu-utils libelf-dev autoconf automake libtool autopoint device-tree-compiler ccache xsltproc \
 rename antlr3 gperf curl screen upx-ucl jq

