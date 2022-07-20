#!/bin/env bash

ip=$(curl -s "https://api.vc.bilibili.com/dynamic_svr/v1/dynamic_svr/get_dynamic_detail?dynamic_id=$1" \
	| jq ".data.card.extend_json|fromjson|.from.ip")

curl -s "http://ip-api.com/json/${ip:1:-1}?lang=zh-CN&fields=status,message,country,countryCode,region,regionName,city,lat,lon,timezone,isp,org,as,mobile,query" | jq
