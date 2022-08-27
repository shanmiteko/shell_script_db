#!/bin/env bash
set -e

envf=adrive.env

. $envf

if [[ -z "$ADRIVE_REFRESH_TOKEN" ]]; then
	echo "no refresh token in env"
	exit 0
fi

function left_time() {
	echo $(($(date -d $1 +%s) - $(date +%s)))
}

function lesser() {
	[[ -z "$1" ]] || (($(left_time "$1") < $2))
}

function set_env() {
	while [[ -n "$1" ]]; do
		eval "$1=\"$2\""
		shift
		shift
	done
}

function flush_envf() {
	cat /dev/null >$envf
}

function save_to_envf() {
	while [[ -n "$1" ]]; do
		echo "$1=$(eval echo \$$1)" >>$envf
		shift
	done
}

function jq_parse() {
	echo "$1" | jq -r "$2"
}

function jq_nonnull() {
	echo "$1 as \$value | if \$value == null then error(\"$1: \"+(.|tostring)) else . end"
}

function jq_nonnull_then() {
	echo "$1 as \$value | if \$value == null then error(\"$1: \"+(.|tostring)) else \$value|$2 end"
}

function jq_set() {
	while [[ -n "$1" ]]; do
		set_env $1 $(echo "$2" | jq -r "$(jq_nonnull_then $3 .)")
		shift
		shift
		shift
	done
}

function aget_to() {
	curl -sL "$1" \
		-H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:103.0) Gecko/20100101 Firefox/103.0' \
		-H 'Referer: https://www.aliyundrive.com/' \
		-H 'Origin: https://www.aliyundrive.com' \
		-o "$2"
}

function apost() {
	curl -s "$1" \
		-X POST \
		-H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:103.0) Gecko/20100101 Firefox/103.0' \
		-H 'Referer: https://www.aliyundrive.com/' \
		-H 'Origin: https://www.aliyundrive.com' \
		-H 'Content-Type: application/json;charset=utf-8' \
		-H "Authorization: Bearer $ADRIVE_ACCESS_TOKEN" \
		--data-raw "$2"
}

function adrive_id() {
	apost 'https://api.aliyundrive.com/adrive/v2/user/get' \
		'{}' |
		jq -r "$(jq_nonnull_then .default_drive_id .)"
}

function ad_ls() {
	apost 'https://api.aliyundrive.com/adrive/v3/file/list' \
		"{\"drive_id\":\"$ADRIVE_ID\" ,\"parent_file_id\":\"$1\"}" |
		jq -r "$(jq_nonnull_then .items 'map([.file_id,.type,.name]|join("\t"))|join("\n")')"
}

function file_get() {
	apost 'https://api.aliyundrive.com/v2/file/get' \
		'{"drive_id":"'$ADRIVE_ID'","file_id":"'$1'","image_thumbnail_process":"image/resize,w_400/format,jpeg","image_url_process":"image/resize,w_1920/format,jpeg","url_expire_sec":9000,"video_thumbnail_process":"video/snapshot,t_1000,f_jpg,ar_auto,w_300"}' |
		jq "$(jq_nonnull .name)"
}

function get_video_preview_play_info() {
	apost 'https://api.aliyundrive.com/v2/file/get_video_preview_play_info' \
		"{\"drive_id\":\"$ADRIVE_ID\",\"file_id\":\"$1\",\"category\":\"live_transcoding\",\"template_id\":\"\",\"get_subtitle_info\":true}" |
		jq "$(jq_nonnull_then .video_preview_play_info .)" |
		jq "$(jq_nonnull_then .live_transcoding_task_list .)"
}

function get_remote_m3u8() {
	play_info=$(get_video_preview_play_info $1)
	play_url=$(jq_parse "$play_info" "map(select(.template_id==\"$2\"))|.[0].url")
	echo "$play_url"
}

function refresh_local_m3u8() {
	echo "refresh_local_m3u8"
	aget_to "$1" "$2.m3u8"
	base_url=${1%.m3u8*}
	base_url="${base_url%/*}/"
	base_url="${base_url//\//\\\/}"
	sed -i -e '/^\s/d' -e "/^[^#h]/s/^/$base_url/" "$2.m3u8"
}

function vlc_play() {
	file_info=$(file_get $1)
	file_name=$(jq_parse "$file_info" .name)

	play_info=$(get_video_preview_play_info $1)
	quality_options=$(jq_parse "$play_info" 'map(.template_id)|join(",")')
	read -p "Quality($quality_options): " qua
	if [[ -z "${qua}" ]]; then
		qua=HD
	fi
	play_url=$(jq_parse "$play_info" "map(select(.template_id==\"$qua\"))|.[0].url")
	refresh_local_m3u8 "$play_url" "$1"

	read -p "play(p) or download(d)? " input
	case "${input}" in
	p)
		vlc "$1.m3u8" \
			--qt-minimal-view \
			--no-qt-name-in-title \
			--meta-title "$file_name" \
			--video-title "$file_name" \
			--input-title-format '$t' &

		while true; do
			sleep 600s
			play_url=$(get_remote_m3u8 "$1" "$qua")
			refresh_local_m3u8 "$play_url" "$1"
		done
		;;
	d)
		sed -i '/^#/d' "$1.m3u8"
		while read line; do
			curl -sL "${line}" \
				-H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:103.0) Gecko/20100101 Firefox/103.0' \
				-H 'Referer: https://www.aliyundrive.com/' \
				-H 'Origin: https://www.aliyundrive.com' \
				--create-dirs \
				--output-dir tmp \
				-o "$(basename ${line%\?*})" &
		done <"$1.m3u8"
		while [[ -n $(pgrep curl) ]]; do
			sleep 2s
			echo "wait 2s..."
		done
		echo "download complete!"
		for i in $(ls tmp/*.ts | sort -V); do
			echo "file '$i'"
		done >>all_ts.tmp
		ffmpeg -f concat -i all_ts.tmp -c copy -bsf:a aac_adtstoasc "$file_name"
		rm all_ts.tmp
		rm -r tmp
		;;
	*)
		echo "nop"
		;;
	esac

}

function refresh_token() {
	echo 'refresh_token'
	resp=$(apost 'https://api.aliyundrive.com/token/refresh' \
		"{\"refresh_token\":\"$ADRIVE_REFRESH_TOKEN\"}")
	jq_set \
		ADRIVE_EXPIRE_TIME $resp .expire_time \
		ADRIVE_ACCESS_TOKEN $resp .access_token \
		ADRIVE_REFRESH_TOKEN $resp .refresh_token
}

function check_token() {
	if $(lesser "$ADRIVE_EXPIRE_TIME" 300); then
		refresh_token
		flush_envf
		save_to_envf \
			ADRIVE_EXPIRE_TIME \
			ADRIVE_ACCESS_TOKEN \
			ADRIVE_REFRESH_TOKEN
	fi
}

check_token

set_env \
	ADRIVE_ID $(adrive_id) \
	_file_id "root" \
	_cmd "" \
	_para ""

while true; do
	check_token

	echo "# ${_file_id}"
	read -p "\$ " cmd para

	if [[ -z "${cmd}" ]]; then
		echo "$_cmd $_para"
		set_env \
			cmd "$_cmd" \
			para "$_para"
	fi

	case "${cmd}" in
	q | quit | exit | bye)
		exit 0
		;;
	ls)
		ad_ls $_file_id
		;;
	cd)
		case "${para}" in
		"") ;;
		*)
			set +o errexit
			ad_ls "$para" && set_env _file_id "$para"
			set -o errexit
			;;
		esac
		;;
	file)
		file_get "$para"
		;;
	pl)
		vlc_play "$para"
		;;
	"") ;;
	*)
		eval "$cmd $para"
		;;
	esac

	set_env \
		_cmd "$cmd" \
		_para "$para"

	echo ""
done
