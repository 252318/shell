#!/bin/bash
####################################################################
#                                                                  #
# Basic Network Check Script for linux                             #
# Created by FanJiaLin, 2021                                       #
#                                                                  #
# This script may be freely used, copied, modified and distributed #
# under the sole condition that credits to the original author     #
# remain intact.                        		   	   #
#				   			           #
# This script comes without any warranty, use it at your own risk. #
#                                                                  #
####################################################################
 
###############################################
# CHANGE THESE OPTIONS TO MATCH YOUR SYSTEM ! #
###############################################
 
gateway_ip=172.16.0.1				 # the ip of gateway

host1_ip=172.16.0.254         			 # host 1
host2_ip=172.16.0.5                     	 # host 2
host3_ip=172.16.0.100                    	 # host 3
host4_ip=172.16.0.101                     	 # host 4
host_count=4					 # the sum of host check(eg host 1,host 2,host 3,host 4,the sumof it is 4).

##################
# END OF OPTIONS #
##################
 
time_date=`date +%F`
test_ip=119.29.29.29
test_domain=www.qq.com
obtain_ipv6_domain=ipv6.ip.sb
padding_aX=****************************************************
padding_aY=----------------------------------------------------

#################
# gateway check	#
#################

echo "$padding_aX"

ping -c1 $gateway_ip &>/dev/null
if [ $? -eq 0 ];then
	hostname_tmp1=`nslookup $gateway_ip` && hostname_tmp2=${hostname_tmp1#*\=\ } && hostname_var=${hostname_tmp2%.*}
	echo -e "\e[40;37m $hostname_var $gateway_ip Gateway is ok ! \e[0m"
else
	echo -e "\e[41;37m $gateway_ip Gateway is bad ! \e[0m"
fi

#################

###############
# PPPoE check #
###############

ping -c1 $test_ip &>/dev/null
if [ $? -eq 0 ];then
	echo -e "\e[40;37m $test_ip PPPoE is OK ! \e[0m"
else
	echo -e "\e[41;37m $test_ip PPPoE is bad ! \e[0m"
fi

###############

#############
# DNS check #
#############

nslookup $test_domain &>/dev/null
if [ $? -eq 0 ];then
	echo -e "\e[40;37m nslookup $test_domain DNS is OK \e[0m"
else
	echo -e "\e[41;37m nslookup $test_domain DNS is bad!!! \e[0m"
fi

#############

######################
# IPV6 address check #
######################

echo $padding_aY
curl $obtain_ipv6_domain &>/dev/null
if [ $? -eq 0 ];then
	echo -e "\e[44;37m IPV6 address curl $obtain_ipv6_domain `curl -s $obtain_ipv6_domain` \e[0m" 
else
	echo -e "\e[41;37m IPV6 address curl $obtain_ipv6_domain is bad!!! \e[0m"
fi
echo $padding_aY

######################

###############
# Hosts check #
###############

for ((i=1; i<=$host_count; i++))
do
	eval ping -c1 \$host${i}_ip &>/dev/null
		if [ $? -eq 0 ];then
			host_ip=`eval echo \\$host${i}_ip`
			hostname_tmp1=`nslookup $host_ip` && hostname_tmp2=${hostname_tmp1#*\=\ } && hostname_var=${hostname_tmp2%.*}
			echo "$host_ip $hostname_var is good !"
		else
			host_ip=`eval echo \\$host${i}_ip`
			echo -e "\e[41;37m$host_ip is bad !!! \e[0m"
		fi
done

###############

echo "$padding_aX"
