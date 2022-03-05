echo "add wget-ssl to executable path to fix helloworld"
ln -s /usr/xxx/wget-ssl /usr/bin/wget-ssl

echo "replace sofware source to tsinghua"
sed -i "s/downloads.openwrt.org/mirrors.tuna.tsinghua.edu.cn\/openwrt/g" feeds.txt
sed -i "/custom/d" feeds.txt

echo "install some utilities tools"
opkg update
opkg install tcpdump lrzsz sysstate
opkg remove vim
opkg install vim-fuller
opkg upgrade luci-theme-bootstrap

echo "add luci option to refresh status per second"
LINE_TO_INSERT=`awk "/main/{print NR}" /etc/config/luci`
sed -i "${LINE_TO_INSERT}i\ \ \ \ \ \ \ \ option\ pollinterval\ '1'" /etc/config/luci
