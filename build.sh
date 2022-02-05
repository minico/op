#
# Copyright (c) 2019-2020 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#
# https://github.com/P3TERX/Actions-OpenWrt
# Description: Build OpenWrt using GitHub Actions
#

#!/bin/bash

if [ $# -ne 1 ];then
  echo "USAGE: $0 defconfig|menuconfig"
  exit 1
fi

#Prepare env
sudo apt-get update
sudo apt-get upgrade

sudo apt-get -y install build-essential asciidoc binutils bzip2 gawk gettext git libncurses5-dev \
 patch python3 python2.7 unzip zlib1g-dev lib32gcc-s1 libc6-dev-i386 subversion flex uglifyjs \
 gcc-multilib g++-multilib p7zip p7zip-full msmtp libssl-dev texinfo libglib2.0-dev xmlto \
 qemu-utils libelf-dev autoconf automake libtool autopoint device-tree-compiler ccache xsltproc \
 rename antlr3 gperf curl screen upx-ucl jq

if [ "$USER" = "root" ]; then
	echo
	echo
	echo "请勿使用root用户编译，换一个普通用户吧~~"
	sleep 3s
	exit 0
fi

#Set variables
export GITHUB_WORKSPACE=`pwd`
CONFIG_TYPE=$1
REPO_URL=https://git.openwrt.org/openwrt/openwrt.git
REPO_BRANCH=v21.02.1
DEVICE=x86
FEEDS_CONF=feeds.conf.default
CONFIG_FILE=.config.x86
DIY_P1_SH=diy-part1.sh
DIY_P2_SH=diy-part2.sh
UPLOAD_BIN_DIR=false
UPLOAD_FIRMWARE=true
UPLOAD_COWTRANSFER=false
UPLOAD_WETRANSFER=false
UPLOAD_RELEASE=true
TZ=Asia/Shanghai


#Clone source code
df -hT $PWD
git clone $REPO_URL -b $REPO_BRANCH openwrt

#Load custom feeds
[ -e $FEEDS_CONF ] && cp $FEEDS_CONF openwrt/feeds.conf.default
chmod +x $DIY_P1_SH
cd openwrt
../$DIY_P1_SH
cd -

#Update feeds
cd openwrt
./scripts/feeds update -a

#Install feeds
#./scripts/feeds install libpam
./scripts/feeds install -a

#Load custom configuration
cd -
[ -e files ] && cp -rf files openwrt/files
[ -e $CONFIG_FILE ] && cp $CONFIG_FILE openwrt/.config
chmod +x $DIY_P2_SH
./$DIY_P2_SH

#Download package
cd openwrt
make $CONFIG_TYPE 
make download -j8
find dl -size -1024c -exec ls -l {} \;
find dl -size -1024c -exec rm -f {} \;
cd -

#Compile the firmware
cd openwrt
echo -e "$(nproc) thread compile"
make -j$(nproc) || make -j1 || make -j1 V=s
echo "::set-output name=status::success"
grep '^CONFIG_TARGET.*DEVICE.*=y' .config | sed -r 's/.*DEVICE_(.*)=y/\1/' > DEVICE_NAME
[ -s DEVICE_NAME ] && echo "DEVICE_NAME=_$(cat DEVICE_NAME)" >> $GITHUB_ENV
echo "FILE_DATE=_$(date +"%Y%m%d%H%M")" >> $GITHUB_ENV
cd -

#Check space usage
run: df -hT

#Organize files
cd openwrt/bin/targets/*/*
#rm -rf packages
echo "FIRMWARE=$PWD" >> $GITHUB_ENV
echo "::set-output name=status::success"
