#!/bin/bash

###############################
#
# Script defaults
#
options=""
ubrid_counter=1
list_of_predefined_ports=""

###############################
#
# get nic interfaces
#
nics=$(ls /sys/class/net/ | grep -i "eth" | sed 's/.*/--dev &/')

###############################
#
# check the needed options for debug and serviceuser
#
if [[ "${UBR_DEBUG}" == "true" ]] || [[ "${UBD_DEBUG}" == "1" ]]; then
    options+="-d "
fi

if [[ "${UBR_SERVICEUSER}" == "true" ]] || [[ "${UBR_SERVICEUSER}" == "1" ]]; then
    echo "OK, you specified to use a serviceuser. Will start the relay processes in user: nobody"
    options+="-u nobody "
fi


###############################
#
# Check if one of the pre-made Options for various protocolls should be started
#
if [[ "${UBR_ENABLE_MDNS}" == "true" ]] || [[ "${UBR_ENABLE_MDNS}" == "1" ]]; then
    echo "I shall start the mDNS Reflector on all interfaces. Starting now..."
    /udp-broadcast-relay-redux $options --id $ubrid_counter --port 5353 --multicast 224.0.0.251 -s 1.1.1.1 $nics &
    ubrid_counter=$((ubrid_counter+1))
    list_of_predefined_ports+="5353 "
fi

if [[ "${UBR_ENABLE_SSDP}" == "true" ]] || [[ "${UBR_ENABLE_SSDP}" == "1" ]]; then
    echo "I shall start the SSDP Reflector on all interfaces. Starting now..."
    /udp-broadcast-relay-redux $options --id $ubrid_counter --port 1900 --multicast 239.255.255.250 $nics &
    ubrid_counter=$((ubrid_counter+1))
    list_of_predefined_ports+="1900 "
fi
if [[ "${UBR_ENABLE_LIFX_BULB}" == "true" ]] || [[ "${UBR_ENABLE_LIFX_BULB}" == "1" ]]; then
    echo "I shall start the LIFX Bulb Reflector on all interfaces. Starting now..."
    /udp-broadcast-relay-redux $options --id $ubrid_counter --port 56700 $nics &
    ubrid_counter=$((ubrid_counter+1))
    list_of_predefined_ports+="56700 "
fi
if [[ "${UBR_ENABLE_HDHOMERUN}" == "true" ]] || [[ "${UBR_ENABLE_HDHOMERUN}" == "1" ]]; then
    echo "I shall start the HDHomerun Reflector on all interfaces. Starting now..."
    /udp-broadcast-relay-redux $options --id $ubrid_counter --port 65001 $nics &
    ubrid_counter=$((ubrid_counter+1))
    list_of_predefined_ports+="65001 "
fi

if [[ "${UBR_ENABLE_WC3}" == "true" ]] || [[ "${UBR_ENABLE_WC3}" == "1" ]]; then
    echo "I shall start the Warcraft 3 Reflector on all interfaces. Starting now..."
    /udp-broadcast-relay-redux $options --id $ubrid_counter --port 6112 $nics &
    ubrid_counter=$((ubrid_counter+1))
    list_of_predefined_ports+="6112 "
fi


##################################
#
# Main Loop if user specified UBR_PORT portnumbers
#
if [ ! -z "${UBR_PORTS}" ]; then
    echo "Compose defines a list of custom udp ports."
    for port in $UBR_PORTS
    do
        echo "Starting Process for Port: $port"
        for test_port in $list_of_predefined_ports
        do
            if [[ "${test_port}" == "${port}" ]]; then
                echo "WARNING: You specified a port from a pre-defined option in your custom udp port list UBR_PORTS. Delete this port immediatly! Port: $port"
                exit 1
            fi
        done
        /udp-broadcast-relay-redux $options --id $ubrid_counter --port $port $nics &
        ubrid_counter=$((ubrid_counter+1))
    done
fi


##################################
#
# END: We did all there was to do. Wait in a infinte loop until a sigterm via dumb-init is signaled. Then we simply terminate the script.
#
while :
do
    sleep 2
done