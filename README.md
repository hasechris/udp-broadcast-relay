UDP Broadcast Relay for Linux / FreeBSD / pfSense
==========================

This program listens for packets on a specified UDP broadcast port. When
a packet is received, it sends that packet to all specified interfaces
but the one it came from as though it originated from the original
sender.

The primary purpose of this is to allow devices or game servers on separated
local networks (Ethernet, WLAN, VLAN) that use udp broadcasts to find each
other to do so.

INSTALL
-------

    make
    cp udp-broadcast-relay-redux /some/where

USAGE
-----

```
./udp-broadcast-relay-redux \
    -id id \
    --port <udp-port> \
    --dev eth0 \
    [--dev eth1...] \
    [--multicast 224.0.0.251] \
    [-s <spoof_source_ip>] \
    [-t <overridden_target_ip>]
```

Docker Compose (used with the container from hasechris92)
-----
```
version: '3.7'

networks:
  ###################################################################
  #
  # this is just my network example. This builds a bridge to a normal linux network bridge. 
  # Effect of this is, i can use subnets from outside the host (aka the networks which directly come into my server from the lan port).
  #
  # ATTENTION: This builds a true OSI Layer-2 network bridge to the docker container.
  #
  # Use your own network if you dont use this special setup.
  #
  #
  #
  docker-vmbr14:
    name: docker-vmbr14
    driver: ipvlan
    driver_opts:
      ipvlan_mode: l2
      parent: vmbr14
    ipam:
      config:
        - subnet: 10.0.14.0/24


services:
  broadcast_relay:
    container_name: broadcast_relay
    image: hasechris92/udp-broadcast-relay:latest
    environment:
      UBR_PORTS: "7 9 1900 27031 27032 27033 27034 27035 27036 60128"    <<<<<< YOUR LIST OF PORTS, seperated with space character
      #
      # OPTIONAL (here the defaults)
      UBR_DEBUG: 0
      UBR_SERVICEUSER: 1
      UBR_ENABLE_MDNS: 1  
      UBR_ENABLE_SSDP: 0
      UBR_ENABLE_LIFX_BULB: 0
      UBR_ENABLE_HDHOMERUN: 0
    restart: always
    networks:
      # network names are sorted "dumbly"
      # eth0
      docker-vmbr14:
        ipv4_address: 10.0.14.3
      # eth1
      docker-vmbr2:
        ipv4_address: 10.0.2.3
      # eth2
      docker-vmbr210:
        ipv4_address: 10.253.42.4
      # eth3
      docker-vmbr5:
        ipv4_address: 10.0.5.3
      # eth4
      docker-vmbr7:
        ipv4_address: 10.0.7.2
      # eth5
      docker-vmbr8:
        ipv4_address: 10.0.8.3

```

- udp-broadcast-relay-redux must be run as root to be able to create a raw
  socket (necessary) to send packets as though they originated from the
  original sender.
- `id` must be unique number between instances. This is used to set the TTL of
  outgoing packets to determine if a packet is an echo and should be discarded.
- Multicast groups can be joined and relayed with
  `--multicast <group address>`.
- The source address for all packets can be modified with `-s <ip>`. This
  is unusual.
- A special source ip of `-s 1.1.1.1` can be used to set the source ip
  to the address of the outgoing interface.
- A special destination ip of `-t 255.255.255.255` can be used to set the
  overriden target ip to the broadcast address of the outgoing interface.
- `-f` will fork the application to the background.

EXAMPLE
-------

#### mDNS / Multicast DNS (Chromecast Discovery + Bonjour + More)
`./udp-broadcast-relay-redux --id 1 --port 5353 --dev eth0 --dev eth1 --multicast 224.0.0.251 -s 1.1.1.1`

(Chromecast requires broadcasts to originate from an address on its subnet)

#### SSDP (Roku Discovery + More)
`./udp-broadcast-relay-redux --id 1 --port 1900 --dev eth0 --dev eth1 --multicast 239.255.255.250`

#### Lifx Bulb Discovery
`./udp-broadcast-relay-redux --id 1 --port 56700 --dev eth0 --dev eth1`

#### Broadlink IR Emitter Discovery
`./udp-broadcast-relay-redux --id 1 --port 80 --dev eth0 --dev eth1`

#### Warcraft 3 Server Discovery
`./udp-broadcast-relay-redux --id 1 --port 6112 --dev eth0 --dev eth1`

#### Relaying broadcasts between two LANs joined by tun-based VPN
This example is from OpenWRT. Tun-based devices don't forward broadcast packets
 so temporarily rewriting the destination address (and then re-writing it back)
 is necessary.

Router 1 (source):

`./udp-broadcast-relay-redux --id 1 --port 6112 --dev br-lan --dev tun0 -t 10.66.2.13`

(where 10.66.2.13 is the IP of router 2 over the tun0 link)

Router 2 (target):

`./udp-broadcast-relay-redux --id 2 --port 6112 --dev br-lan --dev tun0 -t 255.255.255.255`

#### HDHomerun Discovery
`./udp-broadcast-relay-redux --id 1 --port 65001 --dev eth0 --dev eth1`

Note about firewall rules
---

If you are running udp-broadcast-relay-redux on a router, it can be an easy
way to relay broadcasts between VLANs. However, beware that these broadcasts
will not establish a RELATED firewall relationship between the source and
destination addresses.

This means if you have strict firewall rules, the recipient may not be able
to respond to the broadcaster. For instance, the SSDP protocol involves
sending a broadcast packet to port 1900 to discover devices on the network.
The devices then respond to the broadcast with a unicast packet back to the
original sender. You will need to make sure that your firewall rules allow
these response packets to make it back to the original sender.
