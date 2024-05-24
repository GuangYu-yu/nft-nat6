# 简介

mwan3是一个在Openwrt下，多广域网负载平衡/故障转移插件，但是将mwan3与IPv6的负载平衡或故障转移路由策略结合使用需要其他配置，例如NETMAP、NPTv6或NAT66。

这些方法没有直接在mwan3中实现，因此需要额外的配置。比如说移动宽带的源地址发起连接，经过mwan3导流至电信宽带的网关会把它丢弃，导致无法预期工作。此脚本通过前缀转换的方式，实现多线IPv6与mwan3均衡负载，正确进行源地址转换。

此外，可以通过开启防火墙IPv6伪装来简便实现，但并不建议这么做。

[参考](https://www.right.com.cn/forum/thread-8348384-1-1.html)

---

## 使用

> 注意事项：防火墙必须使用Firewall4

1. 编辑 /etc/config/firewall ，把nft脚本添加到防火墙

```
config include
    option path '/usr/nft-nat6.sh'
```

> /usr/nft-nat6.sh 可改成你实际的脚本路径

2. 添加nft-nat6.sh

```
#!/bin/sh
ct=$(ifstatus ct_6 | jsonfilter -e '@["route"][0].source')
cn=$(ifstatus cnc_6 | jsonfilter -e '@["route"][0].source')
cm=$(ifstatus cmcc_6 | jsonfilter -e '@["route"][0].source')
nft add table inet myrules
nft create chain inet myrules srcnat { type nat hook postrouting priority srcnat \; } >>/dev/null 2>&1 || \
nft flush chain inet myrules srcnat
nft add rule inet myrules srcnat oifname "pppoe-ct"  ip6 saddr != $ct snat ip6 prefix to ip6 saddr map { ::/0 : $ct }
nft add rule inet myrules srcnat oifname "pppoe-cnc"  ip6 saddr != $cn snat ip6 prefix to ip6 saddr map { ::/0 : $cn }
nft add rule inet myrules srcnat oifname "pppoe-cmcc"  ip6 saddr != $cm snat ip6 prefix to ip6 saddr map { ::/0 : $cm }
```
> 上传本项目的nft-nat6.sh，或新建nft-nat6.sh，将代码加入

> ct、cn、cm（$ct、$cn、$cm）分别对应中国电信、中国联通、中国移动。根据实际情况修改名称或增删

> ct_6指中国电信DHCPv6

> pppoe-ct指中国电信PPPoE的接口名称

> ::/0可以替换为运营商实际前缀长度，在IPv6-PD的最后查看
