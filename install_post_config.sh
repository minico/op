echo "add wget-ssl to executable path to fix helloworld"
if [ ! -f /usr/bin/wget-ssl ]; then
  ln -s /usr/xxx/wget-ssl /usr/bin/wget-ssl
fi

echo "replace sofware source to tsinghua"
sed -i "s/downloads.openwrt.org/mirrors.tuna.tsinghua.edu.cn\/openwrt/g" /etc/opkg/distfeeds.conf
sed -i "/custom/d" /etc/opkg/distfeeds.conf

echo "install some utilities tools"
opkg update
opkg install tcpdump lrzsz sysstate
opkg remove vim
opkg install vim-fuller
opkg upgrade luci-theme-bootstrap

echo "add luci option to refresh status per second"
grep pollinterval /etc/config/luci
if [ $? == 1 ]; then
  LINE_TO_INSERT=`awk "/main/{print NR}" /etc/config/luci`
  sed -i "${LINE_TO_INSERT} a\ \ \ \ \ \ \ \ option\ pollinterval\ '1'" /etc/config/luci
fi
