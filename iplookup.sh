#!/usr/bin/env bash
hosts=/etc/hosts

domains=(
	duckduckgo.com
	duck.com
	external-content.duckduckgo.com
	links.duckduckgo.com

	nhentai.net
	static.nhentai.net
	t2.nhentai.net
	t5.nhentai.net
	t7.nhentai.net
	i.nhentai.net
	i2.nhentai.net
	i5.nhentai.net
	cdnjs.cloudflare.com

	github.com
	github.githubassets.com
	central.github.com
	desktop.githubusercontent.com
	assets-cdn.github.com
	camo.githubusercontent.com
	github.map.fastly.net
	github.global.ssl.fastly.net
	gist.github.com
	github.io
	api.github.com
	raw.githubusercontent.com
	user-images.githubusercontent.com
	favicons.githubusercontent.com
	avatars5.githubusercontent.com
	avatars4.githubusercontent.com
	avatars3.githubusercontent.com
	avatars2.githubusercontent.com
	avatars1.githubusercontent.com
	avatars0.githubusercontent.com
	avatars.githubusercontent.com
	codeload.github.com
	githubstatus.com
	github.community
	media.githubusercontent.com

	heroku.com
	id.heroku.com

	pixiv.net
	www.pixiv.net

	wikipedia.org
)

iplookup() {
	curl -sd "host=$1" https://www.ipaddress.com/ip-lookup |
		perl -e 'while(<>){/https:\/\/www.ipaddress.com\/ipv4\/((\d+\.){3}\d+)/;if($1){print($1);last}}'
}

printf "lookup ipaddress from https://www.ipaddress.com/ip-lookup ..."

IpAddress+="# Auto Generate on $(date)\n$(
	for domain in "${domains[@]}"; do
		{
			printf "$(iplookup $domain)	$domain\n"
		} &
	done
	wait
)\n# Auto Generate on $(date)\n"

printf "ok\nedit hosts ..."

if [ "$EUID" -ne 0 ]; then
	printf "error\n$IpAddress\nPlease run as root"
else
	sed -i '/^# Auto Generate.*/,/&/d' $hosts
	printf "$IpAddress" >>$hosts
	printf "ok\n"
fi
