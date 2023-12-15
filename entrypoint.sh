#!/bin/bash
options=""
ubrid_counter=1

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
for port in $UBR_PORT
do
    echo "Starting Process for Port: $port"
    /udp-broadcast-relay $options $ubrid_counter $port $nics &
    ubrid_counter=$((ubrid_counter+1))
done

while :
do
    sleep 2
done