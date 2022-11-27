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
VAR_REMOTE_IP=223.5.5.5
VAR_REMOTE_DOMAIN=www.qq.com
VAR_CURL_IPV4=https://api.ipify.org
VAR_CURL_IPV6=https://api64.ipify.org

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
PADDING_A="                                                             GATEWAY Ping:"
PADDING_B="                                                                 WAN Ping:"
PADDING_Y="**************$COLOR_YELLOW Hosts Scanning started at: $(date "+%a %d %b %Y %I:%M:%S %p %Z") $COLOR_RESET**************"

PRINT_PADDING_X(){
    echo "$PADDING_X"
}

##########################
# NETWORK DATA && STATUS #
##########################

INSTALL_COMMAND_IP(){
    VAR_DATA_COMMAND_IP=$(ip a) && VAR_STATUS_COMMAND_IP=true
    if [[ ! $VAR_STATUS_COMMAND_IP = true ]];then
        VAR_NAME_OS=$(uname -s)
        case "$VAR_NAME_OS" in
        Darwin)
            echo "Install Command ip for MacOS."
            curl --remote-name -L https://github.com/brona/iproute2mac/raw/master/src/ip.py
            chmod +x ip.py
            sudo mv ip.py /usr/local/bin/ip
            ;;
        Linux)
            echo "Please Install Command ip for Your Linux OS."
            exit
            ;;
        *)
            echo "The Script Doesn't Support Your OS."
            exit
        esac
    fi
}

INSTALL_COMMAND_IP

NETWORK_DATA_STATUS(){
    COLOR_LOCAL_NETWORK=$COLOR_RED
    COLOR_GATEWAY=$COLOR_RED
    COLOR_WAN=$COLOR_RED
    COLOR_DNS=$COLOR_RED

    VAR_STATUS_LOCAL_NETWORK=OK && COLOR_LOCAL_NETWORK=$COLOR_BLUE

    VAR_IP_LOCAL_TMP1=$VAR_DATA_COMMAND_IP && VAR_IP_LOCAL_TMP2=${VAR_IP_LOCAL_TMP1##*inet } && VAR_IP_LOCAL_MASK=${VAR_IP_LOCAL_TMP2%% brd*} && \
    VAR_IP_LOCAL=${VAR_IP_LOCAL_MASK%/*}
    VAR_NETMASK=${VAR_IP_LOCAL_MASK#*/}

    VAR_IP_GATEWAY_TMP1=$(ip r) && VAR_IP_GATEWAY_TMP2=${VAR_IP_GATEWAY_TMP1#*via } && \
    VAR_IP_GATEWAY=${VAR_IP_GATEWAY_TMP2%% dev*}

    VAR_NAME_GATEWAY_TMP1=$(nslookup "$VAR_IP_GATEWAY") && VAR_NAME_GATEWAY_TMP2=${VAR_NAME_GATEWAY_TMP1#*\=\ } && \
    VAR_NAME_GATEWAY=${VAR_NAME_GATEWAY_TMP2%.*}

    if ping -c1 "$VAR_IP_GATEWAY" &>/dev/null;then
        VAR_STATUS_GATEWAY=OK && COLOR_GATEWAY=$COLOR_BLUE && \
        ping -c1 $VAR_REMOTE_IP &>/dev/null && VAR_STATUS_WAN=OK && COLOR_WAN=$COLOR_BLUE && \
        nslookup $VAR_REMOTE_DOMAIN &>/dev/null && VAR_STATUS_DNS=OK && VAR_ONOFF_IP_ADDRESS=on && COLOR_DNS=$COLOR_BLUE
    else
        ping -c1 $VAR_REMOTE_IP &>/dev/null && VAR_STATUS_WAN=OK && COLOR_WAN=$COLOR_BLUE && \
        VAR_STATUS_GATEWAY=OK && COLOR_GATEWAY=$COLOR_BLUE
        nslookup $VAR_REMOTE_DOMAIN &>/dev/null && VAR_STATUS_DNS=OK && VAR_ONOFF_IP_ADDRESS=on && COLOR_DNS=$COLOR_BLUE
    fi


}

PRINT_NETWORK_DATA_STATUS(){
    echo -e "$STRING_1 $COLOR_LOCAL_NETWORK $VAR_STATUS_LOCAL_NETWORK $COLOR_YELLOW $VAR_IP_LOCAL/$VAR_NETMASK via gateway $VAR_IP_GATEWAY($VAR_NAME_GATEWAY). $COLOR_RESET"
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
        VAR_DATA_IPV4_ADDRESS=$(curl -s "$VAR_CURL_IPV4") && VAR_IPV4_ADDRESS=$VAR_DATA_IPV4_ADDRESS && COLOR_IPV4=$COLOR_WHITE
        VAR_DATA_IPV6_ADDRESS=$(curl -s "$VAR_CURL_IPV6") && VAR_IPV6_ADDRESS=$VAR_DATA_IPV6_ADDRESS && COLOR_IPV6=$COLOR_WHITE
    fi
    echo -e "$STRING_5 $COLOR_IPV4 $VAR_IPV4_ADDRESS $COLOR_RESET"
    echo -e "$STRING_6 $COLOR_IPV6 $VAR_IPV6_ADDRESS $COLOR_RESET"
}
####################

######################
# HOSTS ALIVE in LAN #
######################

PRINT_HOST_ALIVE(){
    echo -e "$PADDING_Y"
    if [[ $VAR_STATUS_LOCAL_NETWORK = OK ]]; then VAR_IP_GATEWAY_PREFIX=${VAR_IP_GATEWAY%.*}; fi
    for ((i = 1; i <= 254; i++)); do
        {
            HOST_IP=$VAR_IP_GATEWAY_PREFIX.$i
            if ping -c1 "$HOST_IP" &>/dev/null; then
                HOSTNAME_TMP1=$(nslookup "$HOST_IP") && HOSTNAME_TMP2=${HOSTNAME_TMP1##*\=\ } && HOSTNAME_VAR=${HOSTNAME_TMP2%.*}
                echo -e "$COLOR_YELLOW $(date "+%a %d %b %Y %I:%M:%S %p %Z"):        $HOST_IP($HOSTNAME_VAR) $COLOR_RESET"
            fi
        } &
    done
    wait &>/dev/null
}

######################

########################
# SPEED DATA && STATUS #
########################

PRINT_SPEED_DATA_STATUS(){
    COLOR_PING_LAN=$COLOR_RED
    COLOR_PING_WAN=$COLOR_RED
    echo "$STRING_7"
    if [[ $VAR_STATUS_GATEWAY = OK ]]; then
        LAN_TIMEOUT1="$(ping -c4 "$VAR_IP_GATEWAY")" && LAN_TIMEOUT2=${LAN_TIMEOUT1##*=} && LAN_TIMEOUT3=${LAN_TIMEOUT2#*/} && \
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

    NETWORK_DATA_STATUS

    PRINT_NETWORK_DATA_STATUS
    PRINT_IP_DATA_STATUS
    PRINT_HOST_ALIVE
    PRINT_SPEED_DATA_STATUS

    PRINT_PADDING_X
}

#######################

PRINT_NETWORK_HEALTH_STATUS