#!/bin/env bash
set -e

space_history() {
	curl -s "https://api.vc.bilibili.com/dynamic_svr/v1/dynamic_svr/space_history?host_uid=$1&offset_dynamic_id=$2"
}

ipgeo() {
	curl -s "https://api.ipgeolocation.io/ipgeo?apiKey=382292a28e93498799cfd4a8a085d76b&ip=$1&fields=country_name,state_prov,district,city&lang=cn"
}

uid=$1
offset=$2
iparr=''
for page in {0..1}
do
	resp="$(space_history $uid $offset)"
	ips=$(echo "$resp" | jq ".data.cards|map(.extend_json|fromjson|.from.ip)" | jq @sh)
	iparr+="${ips:1:-1} "
	offset=$(echo "$resp" | jq ".data.next_offset")
done

iparr=($(echo "$iparr"))
for ip in "${iparr[@]}"
do
	if [[ "$ip" != null ]]; then
		ipgeo ${ip:1:-1} | jq
	fi
done
