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

STRING_1="LOCAL NETWORK:           "
STRING_2="GATEWAY:                 "
STRING_3="WAN:                     "
STRING_4="DNS:                     "
STRING_5="IPV4 ADDRESS:            "
STRING_6="IPV6 ADDRESS:            "

PADDING_X="----------------------------------------------------------------------------------"

echo "$PADDING_X"

#################
# Network check	#
#################

ip r &>/dev/null
if [ $? -eq 0 ];then
    LOCAL_IP_TMP1=`ip r` && LOCAL_IP_TMP2=${LOCAL_IP_TMP1#*src } && LOCAL_IP=${LOCAL_IP_TMP2%% metric*}
    NETMASK_VAR_TMP1=`ip r` && NETMASK_VAR_TMP2=${NETMASK_VAR_TMP1#*/} && NETMASK_VAR=${NETMASK_VAR_TMP2%% dev*}
    GATEWAY_IP_TMP1=`ip r` && GATEWAY_IP_TMP2=${GATEWAY_IP_TMP1#*via } && GATEWAY_IP=${GATEWAY_IP_TMP2%% dev*} && ping -c1 $GATEWAY_IP &>/dev/null
    if [ $? -eq 0 ];then
        HOSTNAME_TMP1=`nslookup $GATEWAY_IP` && HOSTNAME_TMP2=${HOSTNAME_TMP1#*\=\ } && HOSTNAME_VAR=${HOSTNAME_TMP2%.*}
        echo -e "$STRING_1 $COLOR_GREEN $LOCAL_IP/$NETMASK_VAR VIA GATEWAY $GATEWAY_IP($HOSTNAME_VAR). $COLOR_RESET"
        echo -e "$STRING_2 $COLOR_BLUE OK $COLOR_RESET"

        ping -c1 $VAR_REMOTE_IP &>/dev/null
        if [ $? -eq 0 ];then
            echo -e "$STRING_3 $COLOR_BLUE OK $COLOR_RESET"

            nslookup $VAR_REMOTE_DOMAIN &>/dev/null
            if [ $? -eq 0 ];then
                echo -e "$STRING_4 $COLOR_BLUE OK $COLOR_RESET"
            else
                echo -e "$STRING_4 $COLOR_RED BAD $COLOR_RESET"
            fi

        else
            echo -e "$STRING_3 $COLOR_RED BAD $COLOR_RESET"
            echo -e "$STRING_4 $COLOR_RED BAD $COLOR_RESET"
        fi
    else
        echo -e "$STRING_2 $COLOR_RED BAD $COLOR_RESET"
        echo -e "$STRING_3 $COLOR_RED BAD $COLOR_RESET"
        echo -e "$STRING_4 $COLOR_RED BAD $COLOR_RESET"
    fi
else
    echo -e "$STRING_1 $COLOR_RED BAD $COLOR_RESET"
fi

#################

####################
# IP address check #
####################

curl -s $VAR_CURL_IPV4 &>/dev/null
if [ $? -eq 0 ];then
	echo -e "$STRING_5  `curl -s $VAR_CURL_IPV4` "
else
	echo -e "$STRING_5 $COLOR_RED BAD $COLOR_RESET"
fi

curl -s $VAR_CURL_IPV6 &>/dev/null
if [ $? -eq 0 ];then
	echo -e "$STRING_6  `curl -s $VAR_CURL_IPV6` "
else
	echo -e "$STRING_6 $COLOR_RED BAD $COLOR_RESET"
fi

####################

###############
# Hosts check #
###############

echo -e "***********$COLOR_GREEN Hosts Scanning started at: $(date) $COLOR_RESET***********"
ip r &>/dev/null
if [ $? -eq 0 ];then
    GATEWAY_IP_PREFIX1=`ip r` && GATEWAY_IP_PREFIX2=${GATEWAY_IP_PREFIX1#*via} && GATEWAY_IP=${GATEWAY_IP_PREFIX2%%dev*} && GATEWAY_IP_PREFIX=${GATEWAY_IP%.*}
fi

for ((i=1; i<=254; i++))
do
    {
        HOST_IP=$GATEWAY_IP_PREFIX.$i
        ping -c1 $HOST_IP &>/dev/null
            if [ $? -eq 0 ];then
                HOSTNAME_TMP1=`nslookup $HOST_IP` && HOSTNAME_TMP2=${HOSTNAME_TMP1#*\=\ } && HOSTNAME_VAR=${HOSTNAME_TMP2%.*}
                echo -e "$COLOR_YELLOW $(date):    $HOST_IP($HOSTNAME_VAR) $COLOR_RESET"
            fi
    }&
done
wait &>/dev/null

###############

echo "$PADDING_X"
