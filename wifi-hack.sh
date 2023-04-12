#!/bin/env bash

# var
CARD=wlp1s0

read -p "dump|end|quit? " answer
case "${answer}" in
dump)
    # start
    sudo systemctl stop NetworkManager.service

    sudo ip link set $CARD down

    sudo iwconfig $CARD mode Monitor

    # dump
    sudo airodump-ng $CARD
    
    read -p "bssid? " bssid
    read -p "channel? " channel

    sudo airodump-ng --channel $channel \
	    --bssid $bssid \
	    $CARD \
	    -w $CARD-$bssid-$channel
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
