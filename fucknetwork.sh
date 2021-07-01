#!/bin/bash
####################################################################
#                                                                  #
# Basic Network Check Script for linux                             #
# Created by FanJialins, 2021                                      #
#                                                                  #
# This script may be freely used, copied, modified and distributed #
# under the sole condition that credits to the original author     #
# remain intact.                                                   #
#                                                                  #
# This script comes without any warranty, use it at your own risk. #
#                                                                  #
####################################################################

###############################################
# CHANGE THESE OPTIONS TO MATCH YOUR SYSTEM ! #
###############################################

VAR_LOCAL_NETWORK_STATUS=false
VAR_GATEWAY_STATUS=false
VAR_WAN_STATUS=false
VAR_DNS_STATUS=false
VAR_IP_ADDRESS_ONOFF=off
VAR_IPV4_ADDRESS_STATUS=false
VAR_IPV6_ADDRESS_STATUS=false
VAR_REMOTE_IP=119.29.29.29
VAR_REMOTE_DOMAIN=www.qq.com
VAR_CURL_IPV4=ipv4.ip.sb
VAR_CURL_IPV6=ipv6.ip.sb

##################
# END OF OPTIONS #
##################

COLOR_RED="\033[31m"
COLOR_GREEN="\033[32m"
COLOR_BLUE="\033[34m"
COLOR_YELLOW="\033[33m"
COLOR_RESET="\033[0m"

STRING_1="LOCAL NETWORK:              "
STRING_2="GATEWAY:                    "
STRING_3="WAN:                        "
STRING_4="DNS:                        "
STRING_5="IPV4 ADDRESS:               "
STRING_6="IPV6 ADDRESS:               "
STRING_7="LINK SPEED:                 "

PADDING_X="----------------------------------------------------------------------------------------"
PADDING_A="                                                                 LAN Ping:"
PADDING_B="                                                                 WAN Ping:"
PADDING_Y="**************$COLOR_GREEN Hosts Scanning started at: $(date "+%a %d %b %Y %I:%M:%S %p %Z") $COLOR_RESET**************"
PADDING_Z="**************$COLOR_GREEN Speed Testing  started at: $(date "+%a %d %b %Y %I:%M:%S %p %Z") $COLOR_RESET**************"

echo "$PADDING_X"

###################
# DATA and STATUS #
###################

ip r &>/dev/null

# $ curl --remote-name -L https://github.com/brona/iproute2mac/raw/master/src/ip.py
# $ chmod +x ip.py
# $ mv ip.py /usr/local/bin/ip

if [ $? -eq 0 ]; then
    VAR_LOCAL_NETWORK_STATUS="true"
    LOCAL_IP_TMP1=$(ip a) && LOCAL_IP_TMP2=${LOCAL_IP_TMP1##*inet } && LOCAL_IP_MASK=${LOCAL_IP_TMP2%% brd*} && LOCAL_IP=${LOCAL_IP_MASK%/*}
    NETMASK_VAR=${LOCAL_IP_MASK#*/}
    GATEWAY_IP_TMP1=$(ip r) && GATEWAY_IP_TMP2=${GATEWAY_IP_TMP1#*via } && GATEWAY_IP=${GATEWAY_IP_TMP2%% dev*}
    GATEWAY_NAME_TMP1=$(nslookup "$GATEWAY_IP") && GATEWAY_NAME_TMP2=${GATEWAY_NAME_TMP1#*\=\ } && GATEWAY_NAME_VAR=${GATEWAY_NAME_TMP2%.*}

    ping -c1 "$GATEWAY_IP" &>/dev/null && VAR_GATEWAY_STATUS=true
    ping -c1 $VAR_REMOTE_IP &>/dev/null && VAR_WAN_STATUS=true
    nslookup $VAR_REMOTE_DOMAIN &>/dev/null && VAR_DNS_STATUS=true && VAR_IP_ADDRESS_ONOFF=on

fi

###################

#################
# Network check	#
#################

if [[ $VAR_LOCAL_NETWORK_STATUS = true ]]; then
    echo -e "$STRING_1 $COLOR_GREEN $LOCAL_IP/$NETMASK_VAR VIA GATEWAY $GATEWAY_IP($GATEWAY_NAME_VAR). $COLOR_RESET"
else
    echo -e "$STRING_1 $COLOR_RED BAD $COLOR_RESET"
fi

if [[ $VAR_GATEWAY_STATUS = true ]]; then
    echo -e "$STRING_2 $COLOR_BLUE OK $COLOR_RESET"
else
    echo -e "$STRING_2 $COLOR_RED BAD $COLOR_RESET"
fi


if [[ $VAR_WAN_STATUS = true ]]; then
    echo -e "$STRING_3 $COLOR_BLUE OK $COLOR_RESET"
else
    echo -e "$STRING_3 $COLOR_RED BAD $COLOR_RESET"
fi

if [[ $VAR_DNS_STATUS = true ]]; then
    echo -e "$STRING_4 $COLOR_BLUE OK $COLOR_RESET"
else
    echo -e "$STRING_4 $COLOR_RED BAD $COLOR_RESET"
fi

#################

####################
# IP address check #
####################

if [[ $VAR_IP_ADDRESS_ONOFF = on ]];then
    curl -s $VAR_CURL_IPV4 &>/dev/null && VAR_IPV4_ADDRESS_STATUS=true && VAR_IPV4_ADDRESS=$(curl -s $VAR_CURL_IPV4) 
    curl -s $VAR_CURL_IPV6 &>/dev/null && VAR_IPV6_ADDRESS_STATUS=true && VAR_IPV6_ADDRESS=$(curl -s $VAR_CURL_IPV6) 
fi

if [[ $VAR_IPV4_ADDRESS_STATUS = true ]];then
    echo -e "$STRING_5  $VAR_IPV4_ADDRESS"
else
    echo -e "$STRING_5 $COLOR_RED BAD $COLOR_RESET"
fi

if [[ $VAR_IPV6_ADDRESS_STATUS = true ]];then
    echo -e "$STRING_6  $VAR_IPV6_ADDRESS"
else
    echo -e "$STRING_6 $COLOR_RED BAD $COLOR_RESET"
fi

####################

###############
# Hosts check #
###############

echo -e "$PADDING_Y"
if [[ $VAR_LOCAL_NETWORK_STATUS = true ]]; then GATEWAY_IP_PREFIX=${GATEWAY_IP%.*}; fi
for ((i = 1; i <= 254; i++)); do
    {
        HOST_IP=$GATEWAY_IP_PREFIX.$i
        ping -c1 "$HOST_IP" &>/dev/null
        if [ $? -eq 0 ]; then
            HOSTNAME_TMP1=$(nslookup "$HOST_IP") && HOSTNAME_TMP2=${HOSTNAME_TMP1#*\=\ } && HOSTNAME_VAR=${HOSTNAME_TMP2%.*}
            echo -e "$COLOR_YELLOW $(date "+%a %d %b %Y %I:%M:%S %p %Z"):        $HOST_IP($HOSTNAME_VAR) $COLOR_RESET"
        fi
    } &
done
wait &>/dev/null

###############

#############
# Speed Test#
#############

# echo -e "$PADDING_Z"
echo "$STRING_7"
if [[ $VAR_GATEWAY_STATUS = true ]]; then
    LAN_TIMEOUT1="$(ping -c4 "$GATEWAY_IP")" && LAN_TIMEOUT2=${LAN_TIMEOUT1##*=} && LAN_TIMEOUT3=${LAN_TIMEOUT2#*/} && LAN_TIMEOUT=${LAN_TIMEOUT3%%/*}
    echo "$PADDING_A $LAN_TIMEOUT ms"
else
    echo -e "$PADDING_A $COLOR_RED TIMEOUT $COLOR_RESET"
fi

if [[ $VAR_WAN_STATUS = true ]]; then
    WAN_TIMEOUT1="$(ping -c4 "$VAR_REMOTE_IP")" && WAN_TIMEOUT2=${WAN_TIMEOUT1##*=} && WAN_TIMEOUT3=${WAN_TIMEOUT2#*/} && WAN_TIMEOUT=${WAN_TIMEOUT3%%/*}
    echo "$PADDING_B $WAN_TIMEOUT ms"
else
    echo -e "$PADDING_B $COLOR_RED TIMEOUT $COLOR_RESET"
fi

#############

echo "$PADDING_X"
