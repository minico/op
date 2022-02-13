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


df -hT $PWD
if [ -e openwrt ];then
  echo "WARNING: openwrt dir has exited already, will not clone code!"
else
  #Clone source code
  git clone $REPO_URL -b $REPO_BRANCH openwrt
fi

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
./scripts/feeds install -a -p custom
./scripts/feeds install -a

#Load custom configuration
cd -
# The flowing lines used to fix compile issue for helloworld
cp -rf tools/* openwrt/tools
sed -i 's?zstd$?zstd ucl upx\n$(curdir)/upx/compile := $(curdir)/ucl/compile?g' openwrt/tools/Makefile

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

echo "compile success~"
cd -

#Check space usage
df -hT

#Organize files
cd openwrt/bin/targets/*/*
rm -rf packages
