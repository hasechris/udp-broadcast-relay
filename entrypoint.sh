#!/dumb-init /entrypoint.sh
options=""

# get nic interfaces
nics=$(ls /sys/class/net/ | grep -i "eth" )

# check the needed options
if [[ -z "${UBR_DEBUG}" ]]; then
    options+="-d "
fi

if [[ -z $(cat /etc/passwd | grep -i "serviceuser") ]]; then
    options+="-u serviceuser "
fi


# run udp relay
/udp-broadcast-relay $options $UBR_ID $UBR_PORT $nics
