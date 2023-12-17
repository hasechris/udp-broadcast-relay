#!/bin/bash
options=""
ubrid_counter=1

# get nic interfaces
nics=$(ls /sys/class/net/ | grep -i "eth" | sed 's/.*/--dev &/')

# check the needed options
if [[ "${UBR_DEBUG}" == "true" ]] || [[ "${UBD_DEBUG}" == "1" ]]; then
    options+="-d "
fi

if [[ "${UBR_SERVICEUSER}" == "true" ]] || [[ "${UBR_SERVICEUSER}" == "1" ]]; then
    echo "OK, you specified to use a serviceuser. Will start the relay processes in serviceuser"
    options+="-u nobody "
fi


# run udp relay
for port in $UBR_PORT
do
    echo "Starting Process for Port: $port"
    /udp-broadcast-relay $options --id $ubrid_counter --port $port $nics &
    ubrid_counter=$((ubrid_counter+1))
done

while :
do
    sleep 2
done