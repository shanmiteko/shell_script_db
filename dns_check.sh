#!/usr/bin/env bash

if [[ -z "$1" ]]; then
    domain=bilibili.com
else
    domain=$1
fi

if [[ -z "$2" ]]; then
    curl -s https://public-dns.info/nameservers.txt -O
    NAMESERVERS=nameservers.txt
else
    NAMESERVERS=$2
fi

num=0
start=1
range=1000
while true; do
    if [[ -z $(sed -n "$start p" $NAMESERVERS) ]]; then
        break
    fi
    echo "$start - $(($start + $range)):"
    for dns_server in $(sed -n "$start,$(($start + $range)) p" $NAMESERVERS); do
        {
            if [[ -z "${dns_server}" ]]; then
                break
            fi
            if ping -c 1 -w 1 -q $dns_server >/dev/null 2>&1; then
                ip=$(dig +short +timeout=2 @$dns_server $domain A | sed '/^[;\s]/d' | head -n 1)
                if [[ -n "${ip}" ]]; then
                    if curl -s --connect-timeout 2 $ip >/dev/null 2>&1; then
                        echo "  $dns_server -> $ip"
                    else
                        echo "  $dns_server -> $ip x"
                    fi
                fi
            fi
        } &
    done
    wait
    start=$(($start + $range + 1))
done

# $ time ./dns_check bilibili.com
# 1 - 1001:
#   8.8.8.8 -> 120.92.78.97
#   1.1.1.1 -> 139.159.241.37
#   185.222.222.222 -> 8.134.50.24
#   223.6.6.6 -> 139.159.241.37
# 1002 - 2002:
# 2003 - 3003:
# 3004 - 4004:
# 4005 - 5005:
#   9.9.9.9 -> 139.159.241.37
# 5006 - 6006:
#   114.114.114.114 -> 120.92.78.97
#   114.114.115.115 -> 8.134.50.24
# 6007 - 7007:
# 7008 - 8008:
# 8009 - 9009:
# 9010 - 10010:
# 10011 - 11011:
# 11012 - 12012:
# 12013 - 13013:
# 13014 - 14014:
# 14015 - 15015:
# ./dns_check  95.72s user 87.51s system 122% cpu 2:29.32 total

# $ time ./dns_check httpbin.org
# 1 - 1001:
#   8.8.8.8 -> 18.207.88.57
#   1.1.1.1 -> 54.236.79.58
#   223.6.6.6 -> 44.207.168.240
#   185.222.222.222 -> 52.45.189.24
# 1002 - 2002:
# 2003 - 3003:
# 3004 - 4004:
# 4005 - 5005:
#   9.9.9.9 -> 18.207.88.57
#   114.114.115.119 -> 18.207.88.57
# 5006 - 6006:
#   114.114.114.114 -> 44.207.168.240
#   185.184.222.222 -> 52.45.189.24
# 6007 - 7007:
# 7008 - 8008:
# 8009 - 9009:
# 9010 - 10010:
# 10011 - 11011:
# 11012 - 12012:
# 12013 - 13013:
# 13014 - 14014:
# 14015 - 15015:
# ./dns_check httpbin.org  102.64s user 90.18s system 125% cpu 2:34.18 total

# $ time ./dns_check wikipedia.org
# 1 - 1001:
# 1002 - 2002:
# 2003 - 3003:
# 3004 - 4004:
# 4005 - 5005:
# 5006 - 6006:
# 6007 - 7007:
# 7008 - 8008:
# 8009 - 9009:
# 9010 - 10010:
# 10011 - 11011:
# 11012 - 12012:
# 12013 - 13013:
# 13014 - 14014:
# 14015 - 15015:
# ./dns_check wikipedia.org  118.43s user 105.10s system 183% cpu 2:02.07 total

# $ time ./dns_check duckduckgo.com
# 1 - 1001:
# 1002 - 2002:
# 2003 - 3003:
# 3004 - 4004:
# 4005 - 5005:
# 5006 - 6006:
# 6007 - 7007:
# 7008 - 8008:
# 8009 - 9009:
# 9010 - 10010:
# 10011 - 11011:
# 11012 - 12012:
# 12013 - 13013:
# 13014 - 14014:
# 14015 - 15015:
# ./dns_check duckduckgo.com  119.37s user 108.07s system 187% cpu 2:01.13 total
