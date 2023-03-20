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
openwrt_version="22.03.3"
case $openwrt_version in
    "22.03.3")
        kernel_md5="2974fbe1fa59be88f13eb8abeac8c10b"
        ;;
    "22.03.2")
        kernel_md5="c91e62db69d188afca1b6cc5c9e1b72d"
        ;;
    "21.02.5")
        kernel_md5="24ba228d1c9cc0e5974cb09dca64f48e"
        ;;
esac

echo "-----------------Modify default IP"
sed -i 's/192.168.1.1/192.168.68.1/g' package/base-files/files/bin/config_generate
grep  192 -n3 package/base-files/files/bin/config_generate

echo '-----------------修改时区为东八区'
sed -i "s/'UTC'/'CST-8'\n        set system.@system[-1].zonename='Asia\/Shanghai'/g" package/base-files/files/bin/config_generate


echo '-----------------修改主机名为 Luban'
sed -i 's/OpenWrt/Luban/g' package/base-files/files/bin/config_generate

grep timezone -n5 package/base-files/files/bin/config_generate

echo '-----------------默认开启wifi'
sed -i '/disabled=1/d' package/kernel/mac80211/files/lib/wifi/mac80211.sh 
grep "devidx}.htmode" -n5 package/kernel/mac80211/files/lib/wifi/mac80211.sh 

echo "'-----------------自定义软件源"
#sed -i 's#downloads.openwrt.org#mirrors.cloud.tencent.com/openwrt#g' /etc/opkg/distfeeds.conf
echo "src/gz openwrt_core http://mirrors.cloud.tencent.com/lede/releases/${openwrt_version}/targets/ramips/mt7621/packages" >> package/system/opkg/files/customfeeds.conf
echo "src/gz openwrt_base http://mirrors.cloud.tencent.com/lede/releases/${openwrt_version}/packages/mipsel_24kc/base" >> package/system/opkg/files/customfeeds.conf
echo "src/gz openwrt_luci http://mirrors.cloud.tencent.com/lede/releases/${openwrt_version}/packages/mipsel_24kc/luci" >> package/system/opkg/files/customfeeds.conf
echo "src/gz openwrt_packages http://mirrors.cloud.tencent.com/lede/releases/${openwrt_version}/packages/mipsel_24kc/packages" >> package/system/opkg/files/customfeeds.conf
echo "src/gz openwrt_routing http://mirrors.cloud.tencent.com/lede/releases/${openwrt_version}/packages/mipsel_24kc/routing" >> package/system/opkg/files/customfeeds.conf
echo "src/gz openwrt_telephony http://mirrors.cloud.tencent.com/lede/releases/${openwrt_version}/packages/mipsel_24kc/telephony" >> package/system/opkg/files/customfeeds.conf
cat package/system/opkg/files/customfeeds.conf

echo "-----------------修改u-boot的ramips"
sed -i 's/yuncore,ax820/jdcloud,luban/g' package/boot/uboot-envtools/files/ramips

grep all5002 -n5 package/boot/uboot-envtools/files/ramips

echo '-----------------载入 mt7621_jdcloud_luban.dts'
curl --retry 3 -s --globoff "https://gist.githubusercontent.com/vki888/9311d2b0854849f2f8eb3d89e5fb099b/raw/4d07a9f5f43010492baecc196bc701279ed67b50/%255Bopenwrt%255Dmt7621_jdcloud_luban_2.dts" -o target/linux/ramips/dts/mt7621_jdcloud_luban.dts
cat target/linux/ramips/dts/mt7621_jdcloud_luban.dts

# fix2 + fix4.2
echo '-----------------修补 mt7621.mk'
grep adslr_g7 -n10 target/linux/ramips/image/mt7621.mk
sed -i '/Device\/adslr_g7/i\define Device\/jdcloud_luban\n  \$(Device\/dsa-migration)\n  \$(Device\/uimage-lzma-loader)\n  IMAGE_SIZE := 15808k\n  DEVICE_VENDOR := JDCloud\n  DEVICE_MODEL := luban\n  DEVICE_PACKAGES := kmod-fs-ext4 kmod-mt7915e kmod-sdhci-mt7620 uboot-envtools kmod-mmc kmod-mtk-hnat kmod-mtd-rw wpad-openssl\nendef\nTARGET_DEVICES += jdcloud_luban\n\n' target/linux/ramips/image/mt7621.mk
grep adslr_g7 -n10 target/linux/ramips/image/mt7621.mk

# fix3 + fix5.2
echo '-----------------修补 02-network'
sed -i '/xiaomi,redmi-router-ac2100/i\jdcloud,luban|\\' target/linux/ramips/mt7621/base-files/etc/board.d/02_network
grep xiaomi,redmi-router-ac2100 -n3 target/linux/ramips/mt7621/base-files/etc/board.d/02_network

#失败的配置，备份
#sed -i -e '/hiwifi,hc5962|\\/i\jdcloud,luban|\\' -e '/ramips_setup_macs/,/}/{/ampedwireless,ally-00x19k/i\jdcloud,luban)\n\t\t[ "$PHYNBR" -eq 0 \] && echo $label_mac > /sys${DEVPATH}/macaddress\n\t\t\[ "$PHYNBR" -eq 1 \] && macaddr_add $label_mac 0x800000 > /sys${DEVPATH}/macaddress\n\t\t;;
#}' target/linux/ramips/mt7621/base-files/etc/board.d/02_network

#失败的配置，备份
#sed -i '/ampedwireless,ally-00x19k|\\/i\jdcloud,luban)\n\t\tucidef_add_switch "switch0" \\ \n\t\t"0:lan" "1:lan" "2:lan" "3:lan" "4:wan" "6u@eth0" "5u@eth1"\n\t\t;;' target/linux/ramips/mt7621/base-files/etc/board.d/02_network

#sed -i -e '/hiwifi,hc5962|\\/i\jdcloud,luban|\\' -e '/ramips_setup_macs/,/}/{/ampedwireless,ally-00x19k/i\jdcloud,luban)\n\t\techo "dc:d8:7c:50:fa:ae" > /sys/devices/platform/1e100000.ethernet/net/eth0/address\n\t\techo "dc:d8:7c:50:fa:af" > /sys/devices/platform/1e100000.ethernet/net/eth1/address\n\t\t;;
#}' target/linux/ramips/mt7621/base-files/etc/board.d/02_network

#cat target/linux/ramips/mt7621/base-files/etc/board.d/02_network

# fix5.1
#echo '修补 system.sh 以正常读写 MAC'
#sed -i 's#key"'\''=//p'\''#& \| head -n1#' package/base-files/files/lib/functions/system.sh

#借用lede的
#sed -i '/pcie: pcie@1e140000/i\hnat: hnat@1e100000 {\n\tcompatible = "mediatek,mtk-hnat_v1";\n\text-devices = "ra0", "rai0", "rax0",\n\t\t"apcli0", "apclii0","apclix0";\n\treg = <0x1e100000 0x3000>;\n\n\tresets = <&ethsys 0>;\n\treset-names = "mtketh";\n\n\tmtketh-wan = "wan";\n\tmtketh-ppd = "lan";\n\tmtketh-lan = "lan";\n\tmtketh-max-gmac = <1>;\n\tmtkdsa-wan-port = <4>;\n\t};\n\n'  ./target/linux/ramips/dts/mt7621.dtsi
#sed -i '/pcie: pcie@1e140000/i\gsw: gsw@1e110000 {\n\tcompatible = "mediatek,mt753x";\n\treg = <0x1e110000 0x8000>;\n\tinterrupt-parent = <&gic>;\n\tinterrupts = <GIC_SHARED 23 IRQ_TYPE_LEVEL_HIGH>;\n\n\tmediatek,mcm;\n\tmediatek,mdio = <&mdio>;\n\tmt7530,direct-phy-access;\n\n\tresets = <&rstctrl 2>;\n\treset-names = "mcm";\n\tstatus = "disabled";\n\n\tport@5 {\n\n\tcompatible = "mediatek,mt753x-port";\n\treg = <5>;\n\tphy-mode = "rgmii";\n\tfixed-link {\n\tspeed = <1000>;\n\tfull-duplex;\n\t};\n\t};\n\n\tport@6 {\n\tcompatible = "mediatek,mt753x-port";\n\treg = <6>;\n\tphy-mode = "rgmii";\n\n\tfixed-link {\n\tspeed = <1000>;\n\tfull-duplex;\n\t};\n\t};\n\t};\n\t'  ./target/linux/ramips/dts/mt7621.dtsi
#sed -i '/ethernet: ethernet@1e100000 {/i\ethsys: ethsys@1e000000 {\n\tcompatible = "mediatek,mt7621-ethsys",\n\t\t"syscon";\n\treg = <0x1e000000 0x1000>;\n\t#clock-cells = <1>;\n\t};\n\n'  ./target/linux/ramips/dts/mt7621.dtsi	

echo '-----------------定义kernel MD5，与官网一致'
echo ${kernel_md5} > ./.vermagic
cat .vermagic

sed -i 's/^\tgrep.*vermagic/\tcp -f \$(TOPDIR)\/\.vermagic \$(LINUX_DIR)\/\.vermagic/g' include/kernel-defaults.mk
grep vermagic -n5 include/kernel-defaults.mk
