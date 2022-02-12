#!/bin/bash
#
# Copyright (c) 2019-2020 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part1.sh
# Description: OpenWrt DIY script part 1 (Before Update feeds)
#

# Uncomment a feed source
#sed -i 's/^#\(.*helloworld\)/\1/' feeds.conf.default

# Add a feed source
#echo 'src-git helloworld https://github.com/fw876/helloworld' >>feeds.conf.default
#echo 'src-git passwall https://github.com/xiaorouji/openwrt-passwall' >>feeds.conf.default

#not need telephony feeds
sed -i 's/src-git telephony/#src-git telephony/g' feeds.conf.default

cat >> feeds.conf.default <<EOF
#src-git kiddin9 https://github.com/kiddin9/openwrt-packages
#src-git liuran001 https://github.com/liuran001/openwrt-packages
src-git custom https://github.com/minico/openwrt-packages
EOF

# remove duplicate lines when the script run the 2nd time
awk ' !x[$0]++' feeds.conf.default > tmp.conf
cp tmp.conf feeds.conf.default && rm -rf tmp.conf

# install some other apps
sed -i "s/DEFAULT_PACKAGES:=/DEFAULT_PACKAGES:=dnsmasq-full wget-ssl lrzsz sysstat tcpdump curl htop bash vim /" include/target.mk
sed -i "/dnsmasq \\\/d" include/target.mk
