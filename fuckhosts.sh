#!/bin/bash
####################################################################
#                                                                  #
# Host Alive Check Script for linux                                #
# Created by FanJialins 2021                                       #
#                                                                  #
# This script may be freely used, copied, modified and distributed #
# under the sole condition that credits to the original author     #
# remain intact.                                                   #
#                                                                  #
# This script comes without any warranty, use it at your own risk. #
#                                                                  #
####################################################################

COLOR_RED="\033[31m"
COLOR_GREEN="\033[32m"
COLOR_BLUE="\033[34m"
COLOR_YELLOW="\033[33m"
COLOR_RESET="\033[0m"

PADDING_X="----------------------------------------------------------------------------------"
echo "$PADDING_X"

###############
# Hosts check #
###############

echo -e "***********$COLOR_GREEN Hosts Scanning started at: $(date) $COLOR_RESET***********"
ip r &>/dev/null
if [ $? -eq 0 ];then
    GATEWAY_IP_PREFIX1=`ip r` && GATEWAY_IP_PREFIX2=${GATEWAY_IP_PREFIX1#*via } && GATEWAY_IP=${GATEWAY_IP_PREFIX2%%dev*} && GATEWAY_IP_PREFIX=${GATEWAY_IP%.*}
fi

for ((i=1; i<=254; i++))
do
    {
        HOST_IP=$GATEWAY_IP_PREFIX.$i
        ping -c1 $HOST_IP &>/dev/null
            if [ $? -eq 0 ];then
                HOSTNAME_TMP1=`nslookup $HOST_IP` && HOSTNAME_TMP2=${HOSTNAME_TMP1#*\=\ } && HOSTNAME_VAR=${HOSTNAME_TMP2%.*}
                echo -e "$COLOR_YELLOW $(date) $COLOR_BLUE ALIVE $COLOR_RESET $HOST_IP($HOSTNAME_VAR)"
            # else
            #     echo -e "$COLOR_YELLOW $(date) $COLOR_RED DEAD  $COLOR_RESET $HOST_IP"
            fi
    }&
done
wait &>/dev/null

###############
echo "$PADDING_X"