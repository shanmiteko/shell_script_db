#!/bin/sh

GITHUB_HOSTS=$(curl -sSL https://gitee.com/ineo6/hosts/raw/master/hosts)
HOSTS=/etc/hosts

sed -i '/^# GitHub.*/,/&/d' $HOSTS

## "$var"输出时保留换行
echo "$GITHUB_HOSTS" >> $HOSTS
