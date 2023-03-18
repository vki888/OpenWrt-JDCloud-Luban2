#!/bin/sh

# 使能自动挂载
uci set fstab.@global[0].anon_mount=1
uci commit fstab

# 更换腾讯源
sed -i 's#downloads.openwrt.org#mirrors.cloud.tencent.com/openwrt#g' /etc/opkg/distfeeds.conf