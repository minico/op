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
echo "############# run diy part1 in openwrt directory ##############"

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
#sed -i "s/DEFAULT_PACKAGES:=/DEFAULT_PACKAGES:=dnsmasq-full wget-ssl lrzsz sysstat tcpdump curl htop bash vim /" include/target.mk
#sed -i "/dnsmasq \\\/d" include/target.mk

# apply patches
### patch for disable resolve ipv6 address
patch -Np1 <$GITHUB_WORKSPACE/patch/dnsmasq/dnsmasq-add-filter-aaaa-option.patch
patch -Np1 <$GITHUB_WORKSPACE/patch/dnsmasq/luci-add-filter-aaaa-option.patch
cp -f $GITHUB_WORKSPACE/patch/dnsmasq/900-add-filter-aaaa-option.patch ./package/network/services/dnsmasq/patches/900-add-filter-aaaa-option.patch

### Fullcone-NAT 部分 ###
# Patch Kernel 以解决 FullCone 冲突
#pushd target/linux/generic/hack-5.4
#wget https://github.com/coolsnowwolf/lede/raw/master/target/linux/generic/hack-5.4/952-net-conntrack-events-support-multiple-registrant.patch
#popd
cp -f $GITHUB_WORKSPACE/patch/firewall/952-net-conntrack-events-support-multiple-registrant.patch ./target/linux/generic/hack-5.4

# Patch FireWall 以增添 FullCone 功能
mkdir -p package/network/config/firewall/patches
#wget -P package/network/config/firewall/patches/ https://github.com/immortalwrt/immortalwrt/raw/master/package/network/config/firewall/patches/fullconenat.patch
cp $GITHUB_WORKSPACE/patch/firewall/fullconenat.patch ./package/network/config/firewall/patches/
#wget -qO- https://github.com/msylgj/R2S-R4S-OpenWrt/raw/21.02/PATCHES/001-fix-firewall-flock.patch | patch -p1
patch -Np1 <$GITHUB_WORKSPACE/patch/firewall/001-fix-firewall-flock.patch

# Patch LuCI 以增添 FullCone 开关
patch -Np1 <$GITHUB_WORKSPACE/patch/firewall/luci-app-firewall_add_fullcone.patch
# FullCone 相关组件
#svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/openwrt-fullconenat package/lean/openwrt-fullconenat
#mkdir -p package/lean/openwrt-fullconenat
#cp -rf $GITHUB_WORKSPACE/patch/fullconenat/* ./package/lean/openwrt-fullconenat/ 
#pushd package/lean/openwrt-fullconenat
#patch -Np2 <$GITHUB_WORKSPACE/patch/firewall/fullcone6.patch
#popd
