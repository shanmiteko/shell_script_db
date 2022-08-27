#!/usr/bin/env bash

set -e

UA="Mozilla/5.0 (X11; Linux x86_64; rv:94.0) Gecko/20100101 Firefox/94.0"

LIVE_BASE_URI="https://live.bilibili.com"

# 0 - flv
# 1 - ts
STREAM_TYPE=0

if [[ $1 == "-h" ]]; then
	echo "$0 <房间ID> [COOKIE]"
	exit 0
fi

if [[ -n $1 ]]; then
	ROOMID=$1
else
	echo "$0 <房间ID>"
	exit 0
fi

if [[ -n $2 ]]; then
	COOKIE=$2
fi

LIVEURL="$LIVE_BASE_URI/$ROOMID"

LIVE_HTML=$(
	curl -sSL "$LIVEURL" --user-agent "$UA" --cookie "$COOKIE"
)

LIVE_INFO_JSON=$(
	echo $LIVE_HTML |
		tr "\n" " " |
		sed -r "s/.*?__NEPTUNE_IS_MY_WAIFU__=([^<]+).*/\1/g"
)

if [[ $LIVE_INFO_JSON =~ ^\{.*\}$ ]]; then
	echo "有效直播间"
else
	echo "无效直播间"
	exit 0
fi

LIVE_STREAM_URL=$(
	echo $LIVE_INFO_JSON |
		jq -r ".roomInitRes.data.playurl_info.playurl?.stream[$STREAM_TYPE].format[0].codec[0]|(.url_info[0]|.host)+.base_url+(.url_info[0]|.extra)"
)

if [[ $LIVE_STREAM_URL == "null" ]]; then
	echo "当前未直播"
	exit 0
fi

ffplay "$LIVE_STREAM_URL"
# cvlc "$LIVE_STREAM_URL"
