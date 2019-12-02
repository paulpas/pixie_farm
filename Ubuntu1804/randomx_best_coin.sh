#!/usr/bin/env bash

function hash() {
	for i in $(arp -n | grep -v incomplete | grep bond0 | awk "{print \$1}"); do
		nc -w 1 $i 22 </dev/null &>/dev/null \
		&& (ssh -o "StrictHostKeyChecking=no" $i journalctl -xe -u xmrig 2>/dev/null | grep [s]peed | tail -1 & wait)
       	done
}
function hash_total() {
	hash | awk -v N=8 '{ sum += $N } END { if (NR > 0) print sum  }'
}

HASHRATE=$(hash_total)
# Total Watts for all rigs
# I just know it's 625w, I don't have API access to my smart outlets yet
WATTS=625
KWH=0.13111
XMRAPIurl="https://whattomine.com/coins/101-xmr-randomx.json?utf8=%E2%9C%93&hr=${HASHRATE}&p=${WATTS}&fee=0.0&cost=${KWH}"
LOKIAPIurl="https://whattomine.com/coins/249-loki-randomxl.json?utf8=%E2%9C%93&hr=${HASHRATE}&p=${WATTS}&fee=0.0&cost=${KWH}"


for i in "$XMRAPIurl" "$LOKIAPIurl"; do
	output=$(curl -s "$i")
	tag=$(echo $output | jq '.tag' | sed -e 's/"//g')
	revenue=$(echo $output | jq '.revenue' | sed -e 's/"//g')
	profit=$(echo $output | jq '.profit' | sed -e 's/"//g')
	echo "Revenue: $tag: $revenue"
	echo "Profit: $tag: $profit"
done | sort -rnk 2,2

