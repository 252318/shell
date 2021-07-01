#!/bin/bash
####################################################################
#                                                                  #
# Host Alive Check Script for linux                                #
# Created by 252318, 2021                                          #
#                                                                  #
# This script may be freely used, copied, modified and distributed #
# under the sole condition that credits to the original author     #
# remain intact.                                                   #
#                                                                  #
# This script comes without any warranty, use it at your own risk. #
#                                                                  #
####################################################################

###############
# Hosts check #
###############

ip r &>/dev/null
if [ $? -eq 0 ];then
    gateway_ip_prefix1=`ip r` && gateway_ip_prefix2=${gateway_ip_prefix1#*via} && gateway_ip_prefix3=${gateway_ip_prefix2%%dev*} && gateway_ip_prefix=${gateway_ip_prefix3%.*}
fi

for ((i=1; i<=254; i++))
do
    {
        host_ip=$gateway_ip_prefix.${i}
        ping -c1 $host_ip &>/dev/null
            if [ $? -eq 0 ];then
                hostname_tmp1=`nslookup $host_ip` && hostname_tmp2=${hostname_tmp1#*\=\ } && hostname_var=${hostname_tmp2%.*}
                echo -e "\e[44;37m $host_ip $hostname_var is alive.\e[0m" 
            else
                echo -e "\e[41;37m $host_ip is bad !!! \e[0m"
            fi
    }&
done
wait &>/dev/null

###############
