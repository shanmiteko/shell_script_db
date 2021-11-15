#!/bin/bash
set -e

UA="Mozilla/5.0 (X11; Linux x86_64; rv:94.0) Gecko/20100101 Firefox/94.0"

LIVE_BASE_URI="https://live.bilibili.com"

# 0 - flv
# 1 - ts
STREAM_TYPE=0

if [[ -n $1 ]]; then
	ROOMID=$1
else
	echo "$0 <房间ID>"
	exit 0
fi

if [[ -n $2 ]]; then
	COOKIE=$2
else
	echo "$0 $1 <COOKIE>"
fi

LIVEURL=$LIVE_BASE_URI/$ROOMID

LIVE_HTML=$(curl --user-agent "$UA" --cookie $2 -sL "$LIVEURL")

LIVE_INFO_JSON=$(
	echo $LIVE_HTML |
		tr "\n" " " |
		sed -r "s/.*?__NEPTUNE_IS_MY_WAIFU__=([^<]+).*/\1/g"
)

LIVE_STREAM_URL=$(
	echo $LIVE_INFO_JSON |
		jq ".roomInitRes .data .playurl_info .playurl .stream [$STREAM_TYPE] .format [0] .codec [0] | (.url_info [0] | .host) + .base_url + (.url_info [0] | .extra)"
)

ffplay ${LIVE_STREAM_URL:1:-1}
