#!/bin/bash

enable_dns_port () {
    echo "Allowing PORT 53 - IN/OUT"
    ufw allow out 53 #Allow port 53 on all interface for initial VPN connection
    ufw allow in 53
}

disable_dns_port () {
    echo "Blocking PORT 53 - IN/OUT"
    ufw delete allow out 53 #Remove Local DNS Port to prevent leaks
    ufw delete allow in 53
}

ufw enable #Start Firewall

FILE=/usr/local/cyberghost/uninstall.sh
if [ ! -f "$FILE" ]; then
    echo "CyberGhost CLI not installed. Installing..."
    bash /install.sh
    echo "Installed"
fi

FIREWALL_FILE=/.FIREWALL.cg
if [ ! -f "$FIREWALL_FILE" ]; then
    echo "Initiating Firewall First Time Setup..."
    sysctl -w net.ipv6.conf.all.disable_ipv6=1 #Disable IPV6
    sysctl -w net.ipv6.conf.default.disable_ipv6=1
    sysctl -w net.ipv6.conf.lo.disable_ipv6=1
    sysctl -w net.ipv6.conf.eth0.disable_ipv6=1
    sysctl -w net.ipv4.ip_forward=1

    ufw disable #Stop Firewall
    export CYBERGHOST_API_IP=$(getent ahostsv4 v2-api.cyberghostvpn.com | grep STREAM | head -n 1 | cut -d ' ' -f 1)
    ufw default deny outgoing #Deny All traffic by default on all interfaces
    ufw default deny incoming
    ufw allow out on cyberghost from any to any #Allow All over cyberghost interface
    ufw allow in on cyberghost from any to any
    ufw allow in 1337 #Allow port 1337 for CyberGhost Communication
    ufw allow out 1337
    ufw allow out from any to "$CYBERGHOST_API_IP" #Allow v2-api.cyberghostvpn.com [104.20.0.14] IP for connection
    ufw allow in from "$CYBERGHOST_API_IP" to any

    #Allow all ports in ALLOW_PORTS ENV [Separate by ',']
    if [ -n "${ALLOW_PORTS}" ]; then
        echo "Setting Whitelisted Ports..."
        IFS=',' read -a array <<< "$ALLOW_PORTS"
        for i in "${array[@]}"
        do
            echo "Whitelisting Port:" "$i"
            ufw allow "$i"
        done
    fi

    ufw enable #Start Firewall
    echo "Firewall Setup Complete"
    echo 'FIREWALL ACTIVE WHEN FILE EXISTS' > .FIREWALL.cg
fi

#Login to account if config not exist
config_ini=/home/root/.cyberghost/config.ini
if [ ! -f "$config_ini" ]; then
    echo "Logging into CyberGhost..."
    enable_dns_port
    expect /auth.sh
    disable_dns_port
fi

if [ -n "${ALLOW_NETWORK}" ]; then
    echo "Adding network route..."
    export LOCAL_GATEWAY=$(ip r | awk '/^def/{print $3}') # Get local Gateway
    ip route add $ALLOW_NETWORK via $LOCAL_GATEWAY dev eth0 #Enable access to local lan
    echo "$ALLOW_NETWORK" "routed to " "$LOCAL_GATEWAY" " on eth0"
fi


FILE_RUN=/home/root/.cyberghost/run.sh
if [ ! -f "$FILE_RUN" ]; then
    cp /run.sh /home/root/.cyberghost/run.sh
fi

#WIREGUARD START AND WATCH
while true
do
    if [[ $(cyberghostvpn --status | grep 'No VPN connections found.' | wc -l) = "1" ]]; then
        echo 'No VPN Connection - Attempting to connect....'
        enable_dns_port
        bash /home/root/.cyberghost/run.sh #Start the CyberGhost run script
        disable_dns_port
    fi
    sleep 30
done
