#!/bin/env bash

while true; do
	update_num=$(curl -sL 'https://api.bilibili.com/x/polymer/web-dynamic/v1/feed/all/update?type=all&update_baseline=0' \
		-H $'Cookie: SESSDATA=;' |
		jq '.data.update_num')

	if [[ $update_num != "" ]] && [[ $update_num != "0" ]]; then
		kdialog --title B站动态通知 --passivepopup "您有 $update_num 条未读动态" > /dev/null 2>&1
	fi
	echo "[$(date)] [B站动态通知] [您有 $update_num 条未读动态]"
	sleep 300
done
