#!/bin/bash
set -e
echo "gen config.yml..."
curl -SsL https://raw.fastgit.org/oslook/clash-freenode/main/clash.yaml > $CLASH_HOME/config.yaml
# curl -SsL https://raw.fastgit.org/alanbobs999/TopFreeProxies/master/Eternity.yml > $CLASH_HOME/config.yaml
echo "start clash..."
clash -d $CLASH_HOME > $HOME/logs/clash.log 2>&1 &
echo "ok!"
