#!/bin/env bash
set -e

# vard
ip a
echo ""
read -p "which card? " card

read -p "dump|end|quit? " answer
case "${answer}" in
dump)
    # start
    sudo systemctl stop NetworkManager.service

    sudo ip link set $card down

    sudo iwconfig $card mode Monitor

    # dump
    sudo airodump-ng $card
    
    read -p "bssid? " bssid
    read -p "channel? " channel

    sudo airodump-ng --channel $channel \
	    --bssid $bssid \
	    $card \
	    -w $card-$bssid-$channel

    # hack
    #
    # - [ Basic Examples ] -
    # 
    # Attack-          | Hash- |
    # Mode             | Type  | Example command
    # ==================+=======+==================================================================
    # Wordlist         | $P$   | hashcat -a 0 -m 400 example400.hash example.dict
    # Wordlist + Rules | MD5   | hashcat -a 0 -m 0 example0.hash example.dict -r rules/best64.rule
    # Brute-Force      | MD5   | hashcat -a 3 -m 0 example0.hash ?a?a?a?a?a?a
    # Combinator       | MD5   | hashcat -a 1 -m 0 example0.hash example.dict example.dict
    # Association      | $1$   | hashcat -a 9 -m 500 example500.hash 1word.dict -r rules/best64.rule

    # - [ Built-in Charsets ] -
    # 
    #   ? | Charset
    #  ===+=========
    #   l | abcdefghijklmnopqrstuvwxyz [a-z]
    #   u | ABCDEFGHIJKLMNOPQRSTUVWXYZ [A-Z]
    #   d | 0123456789                 [0-9]
    #   h | 0123456789abcdef           [0-9a-f]
    #   H | 0123456789ABCDEF           [0-9A-F]
    #   s |  !"#$%&'()*+,-./:;<=>?@[\]^_`{|}~
    #   a | ?l?u?d?s
    #   b | 0x00 - 0xff
    #
    # hashcat test.txt -a 3 -m 0 --custom-charset1=?l?d ?1?1?1?1?1?1?1?1
    #
    # https://hashcat.net/wiki/doku.php?id=hashcat
    # https://hashcat.net/cap2hashcat/
    
    echo "-> https://hashcat.net/cap2hashcat/"

    ;;
end)
    # end
    sudo ip link set $card down

    sudo iwconfig $card mode Managed

    sudo systemctl restart NetworkManager.service
    ;;
*)
    echo "quit"
    ;;
esac
