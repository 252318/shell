#!/bin/bash
####################################################################
#                                                                  #
# Network Health Check Shellscript for Linux or MacOS.             #
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

LANG=en_US.UTF-8

VAR_STATUS_LOCAL_NETWORK=BAD
VAR_STATUS_GATEWAY=BAD
VAR_STATUS_WAN=BAD
VAR_STATUS_DNS=BAD
VAR_ONOFF_IP_ADDRESS=off
VAR_IPV4_ADDRESS=NONE
VAR_IPV6_ADDRESS=NONE
VAR_TIME_PING_LAN=TIMEOUT
VAR_TIME_PING_WAN=TIMEOUT
VAR_REMOTE_IP=119.29.29.29
VAR_REMOTE_DOMAIN=www.qq.com
VAR_CURL_IPV4=ipv4.ip.sb
VAR_CURL_IPV6=ipv6.ip.sb

##################
# END OF OPTIONS #
##################

COLOR_RED="\033[1;31m"
COLOR_REDS="\033[7;31m"
COLOR_GREEN="\033[1;32m"
COLOR_GREENS="\033[7;32m"
COLOR_YELLOW="\033[1;33m"
COLOR_BLUE="\033[1;34m"
COLOR_BLUES="\033[7;34m"
COLOR_PURPLE="\033[1;35m"
COLOR_WHITE="\033[1;37m"
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
PADDING_Y="**************$COLOR_YELLOW Hosts Scanning started at: $(date "+%a %d %b %Y %I:%M:%S %p %Z") $COLOR_RESET**************"

PRINT_PADDING_X(){
    echo "$PADDING_X"
}

##########################
# NETWORK DATA && STATUS #
##########################

NETWORK_DATA_STATUS(){
    COLOR_LOCAL_NETWORK=$COLOR_RED
    COLOR_GATEWAY=$COLOR_RED
    COLOR_WAN=$COLOR_RED
    COLOR_DNS=$COLOR_RED
    
    ip r &>/dev/null

    # $ curl --remote-name -L https://github.com/brona/iproute2mac/raw/master/src/ip.py
    # $ chmod +x ip.py
    # $ mv ip.py /usr/local/bin/ip

    if [ $? -eq 0 ]; then
        VAR_STATUS_LOCAL_NETWORK=OK && COLOR_LOCAL_NETWORK=$COLOR_BLUE
        LOCAL_IP_TMP1=$(ip a) && LOCAL_IP_TMP2=${LOCAL_IP_TMP1##*inet } && LOCAL_IP_MASK=${LOCAL_IP_TMP2%% brd*} && LOCAL_IP=${LOCAL_IP_MASK%/*}
        NETMASK_VAR=${LOCAL_IP_MASK#*/}
        GATEWAY_IP_TMP1=$(ip r) && GATEWAY_IP_TMP2=${GATEWAY_IP_TMP1#*via } && GATEWAY_IP=${GATEWAY_IP_TMP2%% dev*}
        GATEWAY_NAME_TMP1=$(nslookup "$GATEWAY_IP") && GATEWAY_NAME_TMP2=${GATEWAY_NAME_TMP1#*\=\ } && GATEWAY_NAME_VAR=${GATEWAY_NAME_TMP2%.*}

        ping -c1 "$GATEWAY_IP" &>/dev/null && VAR_STATUS_GATEWAY=OK && COLOR_GATEWAY=$COLOR_BLUE
        ping -c1 $VAR_REMOTE_IP &>/dev/null && VAR_STATUS_WAN=OK && COLOR_WAN=$COLOR_BLUE
        nslookup $VAR_REMOTE_DOMAIN &>/dev/null && VAR_STATUS_DNS=OK && VAR_ONOFF_IP_ADDRESS=on && COLOR_DNS=$COLOR_BLUE
    fi
}

NETWORK_DATA_STATUS

PRINT_NETWORK_DATA_STATUS(){
    echo -e "$STRING_1 $COLOR_LOCAL_NETWORK $VAR_STATUS_LOCAL_NETWORK $COLOR_YELLOW $LOCAL_IP/$NETMASK_VAR via gateway $GATEWAY_IP($GATEWAY_NAME_VAR). $COLOR_RESET"
    echo -e "$STRING_2 $COLOR_GATEWAY $VAR_STATUS_GATEWAY $COLOR_RESET"
    echo -e "$STRING_3 $COLOR_WAN $VAR_STATUS_WAN $COLOR_RESET"
    echo -e "$STRING_4 $COLOR_DNS $VAR_STATUS_DNS $COLOR_RESET"
}

##########################

####################
# IP DATA & STATUS #
####################

PRINT_IP_DATA_STATUS(){
    COLOR_IPV4=$COLOR_RED
    COLOR_IPV6=$COLOR_RED
    if [[ $VAR_ONOFF_IP_ADDRESS = on ]];then
        curl -s $VAR_CURL_IPV4 &>/dev/null && VAR_IPV4_ADDRESS=$(curl -s "$VAR_CURL_IPV4") && COLOR_IPV4=$COLOR_WHITE
        curl -s $VAR_CURL_IPV6 &>/dev/null && VAR_IPV6_ADDRESS=$(curl -s "$VAR_CURL_IPV6") && COLOR_IPV6=$COLOR_WHITE
    fi
    echo -e "$STRING_5 $COLOR_IPV4 $VAR_IPV4_ADDRESS $COLOR_RESET"
    echo -e "$STRING_6 $COLOR_IPV6 $VAR_IPV6_ADDRESS $COLOR_RESET"
}
####################

######################
# HOSTS ALIVE in LAN #
######################

PRINT_HOST_ALIVE(){
    echo -e "**************$COLOR_YELLOW Hosts Scanning started at: $(date "+%a %d %b %Y %I:%M:%S %p %Z") $COLOR_RESET**************"
    if [[ $VAR_STATUS_LOCAL_NETWORK = OK ]]; then GATEWAY_IP_PREFIX=${GATEWAY_IP%.*}; fi
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
}

###############

########################
# SPEED DATA && STATUS #
########################

PRINT_SPEED_DATA_STATUS(){
    COLOR_PING_LAN=$COLOR_RED
    COLOR_PING_WAN=$COLOR_RED
    echo "$STRING_7"
    if [[ $VAR_STATUS_GATEWAY = OK ]]; then
        LAN_TIMEOUT1="$(ping -c4 "$GATEWAY_IP")" && LAN_TIMEOUT2=${LAN_TIMEOUT1##*=} && LAN_TIMEOUT3=${LAN_TIMEOUT2#*/} && \
        VAR_TIME_PING_LAN="${LAN_TIMEOUT3%%/*} ms" && COLOR_PING_LAN=$COLOR_WHITE
    fi

    if [[ $VAR_STATUS_WAN = OK ]]; then
        WAN_TIMEOUT1="$(ping -c4 "$VAR_REMOTE_IP")" && WAN_TIMEOUT2=${WAN_TIMEOUT1##*=} && WAN_TIMEOUT3=${WAN_TIMEOUT2#*/} && \
        VAR_TIME_PING_WAN="${WAN_TIMEOUT3%%/*} ms" && COLOR_PING_WAN=$COLOR_WHITE
    fi
    echo -e "$PADDING_A $COLOR_PING_LAN $VAR_TIME_PING_LAN $COLOR_RESET"
    echo -e "$PADDING_B $COLOR_PING_WAN $VAR_TIME_PING_WAN $COLOR_RESET"
}

########################


#######################
# PRINT Network CHECK #
#######################

PRINT_NETWORK_HEALTH_STATUS(){
    PRINT_PADDING_X
    PRINT_NETWORK_DATA_STATUS
    PRINT_IP_DATA_STATUS
    PRINT_HOST_ALIVE
    PRINT_SPEED_DATA_STATUS
    PRINT_PADDING_X
}

#######################

PRINT_NETWORK_HEALTH_STATUS

