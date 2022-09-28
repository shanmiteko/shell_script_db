#!/bin/bash

COMMAND="$1"

sudo chmod u+x proxy
sudo ./proxy -l 8888 &
chromium-browser --disable-dev-shm-usage > /dev/null 2>&1 &
export http_proxy=http://127.0.0.1:8888
[ -z "$COMMAND" ] && COMMAND=sh
sh -c "$COMMAND"
