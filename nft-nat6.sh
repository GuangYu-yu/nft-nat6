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