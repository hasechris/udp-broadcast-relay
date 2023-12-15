#!/bin/bash
options=""

# get nic interfaces
nics=$(ls /sys/class/net/ | grep -i "eth" )

# check the needed options
if [[ "${UBR_DEBUG}" == "true" ]] || [[ "${UBD_DEBUG}" == "1" ]]; then
    options+="-d "
fi

if [[ "${UBR_SERVICEUSER}" == "true" ]] || [[ "${UBR_SERVICEUSER}" == "1" ]]; then
    options+="-u serviceuser "
fi


# run udp relay
/udp-broadcast-relay $options $UBR_ID $UBR_PORT $nics
