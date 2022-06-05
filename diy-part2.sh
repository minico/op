#!/bin/bash
#
# Copyright (c) 2019-2020 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part2.sh
# Description: OpenWrt DIY script part 2 (After Update feeds)
#

# Modify default IP
#sed -i 's/192.168.1.1/192.168.50.5/g' package/base-files/files/bin/config_generate
echo "############# run diy part2 in openwrt directory ##############"
cp /usr/bin/upx ./staging_dir/host/bin/

# install some other apps
#sed -i "s/DEFAULT_PACKAGES:=/DEFAULT_PACKAGES:=dnsmasq-full wget-ssl lrzsz sysstat tcpdump curl htop bash vim /" include/target.mk
#sed -i "/dnsmasq \\\/d" include/target.mk

# apply patches

### patch for disable resolve ipv6 address
apply_patch_ipv6_dns() {
    patch -Np1 <$GITHUB_WORKSPACE/patch/dnsmasq/dnsmasq-add-filter-aaaa-option.patch
    patch -Np1 <$GITHUB_WORKSPACE/patch/dnsmasq/luci-add-filter-aaaa-option.patch
    cp -f $GITHUB_WORKSPACE/patch/dnsmasq/900-add-filter-aaaa-option.patch ./package/network/services/dnsmasq/patches/900-add-filter-aaaa-option.patch
}

### Fullcone-NAT 部分 ###
apply_patch_full_cone() {
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
}

if [ $APPLY_PATCH = "true" ];then
    apply_patch_ipv6_dns
    apply_patch_full_cone
fi

DATE=`date "+%Y-%m-%d %H:%M"`
sed -i "s/.*github.*/\t\tCompiled by IVAN.ZHANG $DATE/" ./feeds/luci/themes/luci-theme-bootstrap/luasrc/view/themes/bootstrap/footer.htm
sed -i "s/.*ZHANG.*/\t\tCompiled by IVAN.ZHANG $DATE/" ./feeds/luci/themes/luci-theme-bootstrap/luasrc/view/themes/bootstrap/footer.htm
