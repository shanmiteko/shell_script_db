#!/bin/env bash

# var
CARD=wlp1s0

read -rep "dump|end? " -i "quit" answer
case "${answer}" in
dump)
    # start
    sudo systemctl stop NetworkManager.service

    sudo ip link set $CARD down

    sudo iwconfig $CARD mode Monitor

    # hack
    sudo airodump-ng $CARD
    ;;
end)
    # end
    sudo ip link set $CARD down

    sudo iwconfig $CARD mode Managed

    sudo systemctl restart NetworkManager.service
    ;;
*)
    echo "quit"
    ;;
esac
