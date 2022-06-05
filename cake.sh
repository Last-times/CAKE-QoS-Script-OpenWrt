#!/bin/sh
############################################################


### Interfaces ###

## Go to "Network -> Interfaces" and write the name of your "WAN" interface.
WAN="wan"


######################################################################################################################


### CAKE settings ###

BANDWIDTH_DOWN="340"  # Change this to about 80-95% of your download speed (in megabits).
BANDWIDTH_UP="50"     # Change this to about 80-95% of your upload speed (in megabits).
                      # Do a Speed Test: https://www.speedtest.net/
                      # Not recommendable: Write "0" in "BANDWIDTH_DOWN" or "BANDWIDTH_UP" to use 'CAKE' with no limit on the bandwidth ('unlimited' parameter).
                      # Not recommendable: Don't write anything in "BANDWIDTH_DOWN" or "BANDWIDTH_UP" to disable 'shaping' on ingress or egress.

AUTORATE_INGRESS="no"  # Write: "yes" | "no"
                       # Enable CAKE automatic rate estimation for ingress.
                       # For it to work you need to write your bandwidth in "BANDWIDTH_DOWN" to specify an initial estimate.
                       # This is most likely to be useful with "cellular links", which tend to change quality randomly.
                       # If you don't have "cellular link", you should never use this option.

## Make sure you set these parameters correctly for your connection type or don't write any value and use a presets or keywords below.
OVERHEAD=""           # Write values between "-64" and "256"
MPU=""                # Write values between "0" and "256"
LINK_COMPENSATION=""  # Write: "atm" | "ptm" | "noatm"
                      # These values overwrite the presets or keyboards below.
                      # Read: https://openwrt.org/docs/guide-user/network/traffic-shaping/sqm#configuring_the_sqm_bufferbloat_packages
                      # Read: https://openwrt.org/docs/guide-user/network/traffic-shaping/sqm-details#sqmlink_layer_adaptation_tab

## Only use these presets or keywords if you don't write a value above in "OVERHEAD", "MPU" and "LINK_COMPENSATION".
COMMON_LINK_PRESETS="conservative"  # Write the keyword below:
                                    # "raw"              Failsafe     (Turns off all overhead compensation)
                                    # "conservative"     Failsafe     (overhead 48 - atm)
                                    # "ethernet"         Ethernet     (overhead 38 - mpu 84 - noatm)
                                    # "docsis"           Cable Modem  (overhead 18 - mpu 64 - noatm)
                                    # "pppoe-ptm"        VDSL2        (overhead 30 - ptm)
                                    # "bridged-ptm"      VDSL2        (overhead 22 - ptm)
                                    # "pppoa-vcmux"      ADSL         (overhead 10 - atm)
                                    # "pppoa-llc"        ADSL         (overhead 14 - atm)
                                    # "pppoe-vcmux"      ADSL         (overhead 32 - atm)
                                    # "pppoe-llcsnap"    ADSL         (overhead 40 - atm)
                                    # "bridged-vcmux"    ADSL         (overhead 24 - atm)
                                    # "bridged-llcsnap"  ADSL         (overhead 32 - atm)
                                    # "ipoa-vcmux"       ADSL         (overhead 8  - atm)
                                    # "ipoa-llcsnap"     ADSL         (overhead 16 - atm)
                                    # If you are unsure, then write "conservative" as a general safe value.
                                    # These keywords have been provided to represent a number of common link technologies.
                                    ######################################################################################
                                    # For true ATM links (ADSL), one often can measure the real per-packet overhead empirically,
                                    # see: https://github.com/moeller0/ATM_overhead_detector for further information how to do that.

## This keyword is not for standalone use, but act as a modifier to some previous presets or keywords.
ETHER_VLAN_KEYWORD=""  # Write values between "1" and "3" or don't write any value.
                       # In addition to those previous presets or keywords it is common to have VLAN tags (4 extra bytes) or PPPoE encapsulation (8 extra bytes).
                       # "1" Adds '4 bytes' to the overhead  (ether-vlan)
                       # "2" Adds '8 bytes' to the overhead  (ether-vlan ether-vlan)
                       # "3" Adds '12 bytes' to the overhead (ether-vlan ether-vlan ether-vlan)
                       # This keyword "ether-vlan" may be repeated as necessary in 'EXTRA PARAMETERS'.
                       # Read: https://man7.org/linux/man-pages/man8/tc-cake.8.html#OVERHEAD_COMPENSATION_PARAMETERS

PRIORITY_QUEUE_INGRESS="diffserv4"  # Write: "besteffort" | "diffserv3" | "diffserv4" | "diffserv8"
PRIORITY_QUEUE_EGRESS="diffserv4"   # Write: "besteffort" | "diffserv3" | "diffserv4" | "diffserv8"
                                    # CAKE can divide traffic into tins based on the Diffserv field.
                                    # "besteffort" only has 'one tin' or priority tier.
                                    # "diffserv3" has '3 tins' or different priority tiers.
                                    # "diffserv4" has '4 tins' or different priority tiers. <- Recommended
                                    # "diffserv8" has '8 tins' or different priority tiers.

HOST_ISOLATION="yes"  # Write: "yes" | "no"
                      # Host Isolation or 'dual-dsthost' (ingress) and 'dual-srchost' (egress), prevents a single host/client
                      # that has multiple connections (like when torrenting) from hogging all the bandwidth
                      # and provides better traffic management when multiple hosts/clients are using the internet at the same time.

NAT_INGRESS="no"  # Write: "yes" | "no"
NAT_EGRESS="yes"  # Write: "yes" | "no"
                  # Perform a NAT lookup before applying 'host isolation' rules to improve fairness between hosts "inside" the NAT.
                  # Don't use "nat" parameter on 'ingress' when use "veth method" or 'host isolation' stops working.
                  ## Recommendation: Don't use "nat" on 'ingress' and only use "nat" on 'egress'.

WASH_INGRESS="no"  # Write: "yes" | "no"
WASH_EGRESS="yes"  # Write: "yes" | "no"
                   # "wash" only clears all DSCP marks after the traffic has been tinned.
                   # Don't wash incoming (ingress) DSCP marks, because also wash the custom DSCP marking from the script and the script already washes the ISP marks.
                   # Wash outgoing (egress) DSCP marking to ISP, because may be mis-marked from ISP perspective.
                   ## Recommendation: Don't use "wash" on ingress so that the "Wi-Fi Multimedia (WMM) QoS" can make use of the custom DSCP marking and just use "wash" on egress.

INGRESS_MODE="yes"  # Write: "yes" | "no"
                    # Enabling "ingress mode" ('ingress' parameter) will tune the AQM to always keep at least two packets queued *for each flow*.
                    # Basically will drop and/or delay packets in a way that the rate of packets leaving the shaper is smaller or equal to the configured shaper-rate.
                    # This leads to slightly more aggressive dropping, but this also ameliorates one issue we have with post-bottleneck shaping,
                    # namely the inherent dependency of the required bandwidth "sacrifice" with the expected number of concurrent bulk flows.
                    # Thus, being more lenient and keeping a minimum number of packets queued will improve throughput in cases
                    # where the number of active flows are so large that they saturate the bottleneck even at their minimum window size.

ACK_FILTER_EGRESS="auto"  # Write: "yes" | "no" | "auto"
                          # Write "auto" or don't write anything, so that the script decide to use this parameter, depending on the bandwidth you wrote in "BANDWIDTH_DOWN" and "BANDWIDTH_UP".
                          # If your up/down bandwidth is at least 1x15 asymmetric, you can try the 'ack-filter' option.
                          # It doesn't help on your downlink, nor on symmetric links.
                          # 'ack-filter' only makes sense for "egress", so don't add 'ack-filter' keyword for the "ingress" side.
                          # Don't recommend turning it on more symmetrical link bandwidths the effect is negligible at best.

## Don't write 'ms', just write the number.
RTT=""  # Write values between "1" and "1000" or don't write any value to use the default value (100).
        # This parameter defines the time window that your shaper will give the endpoints to react to shaping signals (drops or ECN).
        # The default "100ms" is pretty decent that works for many people, assuming their packets don't always need to cross long distances.
        # If you are based in Europe and access data in California I would assume 200-300ms to be a better value.
        # The general trade off is higher RTTs cause higher bandwidth utilization at the cost of increased latency under load (or rather longer settling times).
        # If your game servers are "40ms" RTT away, you should configure CAKE accordingly (this will lead to some bandwidth sacrifices for flows with a longer RTT).
        # Again setting RTT too high will increase the latency under load (aka the bufferbloat) while increasing bandwidth utilization.
        # You should measure the RTT for CAKE while your network is not loaded.
        # Use ping to measure the Round Trip Time (RTT) on servers you normally connect.
        # Example: ping -c 20 openwrt.org (Linux)
        # Example: ping -n 20 openwrt.org (Windows)

EXTRA_PARAMETERS_INGRESS=""  # Add any custom parameters separated by spaces.
EXTRA_PARAMETERS_EGRESS=""   # Add any custom parameters separated by spaces.
                             # These will be appended to the end of the CAKE options and take priority over the options above.
                             # There is no validation done on these options. Use carefully!
                             # Look: https://man7.org/linux/man-pages/man8/tc-cake.8.html


######################################################################################################################


### Rules settings ###


## Default chain for the rules
CHAIN="FORWARD"  # Write: "FORWARD" | "POSTROUTING"


## DSCP values for the rules
DSCP_ICMP="CS0"    # Change the DSCP value for ICMP (aka ping) to whatever you want.
DSCP_GAMING="CS4"  # You can test changing the DSCP value for games from "CS4" to "EF" or whatever you want.


## Use known rules [OPTIONAL]
BROADCAST_VIDEO="yes"          # Write: "yes" | "no" (Known 'Live Streaming' ports to CS3 like YouTube Live, Twitch, Vimeo and LinkedIn Live)
GAMING="yes"                   # Write: "yes" | "no" (Known 'Game' ports and 'Game consoles' ports to CS4 like Xbox, PlayStation, Call of Duty, FIFA, Minecraft and Supercell Games)
MULTIMEDIA_CONFERENCING="yes"  # Write: "yes" | "no" (Known 'Video conferencing' ports to AF41 like Zoom, Microsoft Teams, Skype, FaceTime, GoToMeeting, Webex Meeting, Jitsi Meet, Google Meet and TeamViewer)
TELEPHONY="yes"                # Write: "yes" | "no" (Known 'VoIP' and 'VoWiFi' ports to EF)

                               # These 4 known port rules are optional.
                               # Only use these rules if you need to prioritize the "specified" traffic
                               # or you can stop using these rules without problems.


############################################################


### Ports settings ###

## Don't add ports "80", "443", "8080" and "1935" below, because there are already rules for these ports.
## You can delete the ports below, because are just examples.


## Game ports (The script already has rules to prioritize "non-bulk" unmarked traffic like gaming and VoIP, which means that adding game ports is optional)
TCP_SRC_GAME_PORTS=""
TCP_DST_GAME_PORTS=""

UDP_SRC_GAME_PORTS=""
UDP_DST_GAME_PORTS=""
                    ## "SRC" = Source port | "DST" = Destination port
                    # Define a list of TCP and UDP ports used by games.
                    # Use a comma to separate the values or ranges A-B as shown.


## Bulk ports
TCP_SRC_BULK_PORTS="6881-6887, 51413"
TCP_DST_BULK_PORTS="6881-6887, 51413"

UDP_SRC_BULK_PORTS="6881-6887, 51413"
UDP_DST_BULK_PORTS="6881-6887, 51413"
                    ## "SRC" = Source port | "DST" = Destination port
                    # Define a list of TCP and UDP ports used for 'bulk traffic' such as "BitTorrent".
                    # Set your "BitTorrent" client to use a known port and include it here.
                    # Use a comma to separate the values or ranges A-B as shown.


## Other ports [OPTIONAL]
DSCP_OTHER_PORTS="CS0"  # Change this DSCP value to whatever you want.

TCP_SRC_OTHER_PORTS=""
TCP_DST_OTHER_PORTS=""

UDP_SRC_OTHER_PORTS=""
UDP_DST_OTHER_PORTS=""
                     ## "SRC" = Source port | "DST" = Destination port
                     # Define a list of TCP and UDP ports to mark wherever you want.
                     # Use a comma to separate the values or ranges A-B as shown.


############################################################


### IP address settings ###

## To add static IP addresses in OpenWrt go to "Network -> DHCP and DNS -> Static Leases -> Click on 'Add'".
## You can delete the IP addresses below, because are just examples.


## Game consoles (Static IP)
IPV4_GAME_CONSOLES_STATIC_IP="192.168.1.15, 192.168.1.20-192.168.1.25"
                              # Define a list of IPv4 addresses that will cover all ports (except ports 80, 443, 8080, Live Streaming and BitTorrent).
                              # Write a single IPv4 address or ranges of IPv4 addresses A-B and use a comma to separate them as shown.
                              # The IPv4 address ranges "192.168.1.20-192.168.1.25" will cover IPv4 addresses from '192.168.1.20' to '192.168.1.25'


IPV6_GAME_CONSOLES_STATIC_IP="IPv6::15, IPv6::20-IPv6::25"
                              # Write the IPv6 address or simply write "IPv6::" to automatically add the IPv6 address of your router
                              # and just change the number "15" (or IP address ranges '20' and '25') to the last number of the static IPv4 of your console.
                              # To add an IPv6 address, simply change the number after the double colon "::" for the last number of your static IPv4 address.
                              # The last number "::15" is the static IPv4 address of '192.168.x.15'
                              # The IPv6 address ranges "::20-::25" will cover static IPv4 addresses from '192.168.x.20' to '192.168.x.25'

## TorrentBox (Static IP)
IPV4_TORRENTBOX_STATIC_IP="192.168.1.10"
                           # Define a list of IPv4 addresses to mark 'all traffic' as bulk.
                           # Write a single IPv4 address or ranges of IPv4 addresses A-B and use a comma to separate them as shown.

IPV6_TORRENTBOX_STATIC_IP="IPv6::10"
                           # Write the IPv6 address or simply write "IPv6::" to automatically add the IPv6 address of your router
                           # and just change the number "10" to the last number of the static IPv4.
                           # To add an IPv6 address, simply change the number after the double colon "::" for the last number of your static IPv4 address.
                           # The last number "::10" is the static IPv4 address of '192.168.x.10'


## Other static IP addresses [OPTIONAL]
DSCP_OTHER_STATIC_IP="CS0"  # Change this DSCP value to whatever you want.

IPV4_OTHER_STATIC_IP=""
IPV6_OTHER_STATIC_IP=""
                      # Define a list of IP addresses to mark 'all traffic' wherever you want.
                      # Write a single IPv4 and IPv6 address or ranges of IP addresses A-B and use a comma to separate them as shown.


######################################################################################################################


### Change default OpenWrt settings ###

DEFAULT_QDISC="cake"  # Write: "fq_codel" | "cake"
                      # "fq_codel" Great all around qdisc. (Default in OpenWrt)
                      # "cake"     Great for WAN links, but computationally expensive with little advantages over 'fq_codel' for LAN links.


TCP_CONGESTION_CONTROL="bbr"  # Write: "cubic" | "bbr"
                              # "cubic" The default algorithm for most Linux platforms. (Default in OpenWrt)
                              # "bbr"   The algorithm that was developed by Google and is since used on YouTube, maybe this can improve network response.


ECN="2"  # Write values between "0" and "2"
         # "0" Disable ECN. Neither initiate nor accept ECN. (Default in OpenWrt)
         # "1" Enable ECN. When requested by incoming connections and also request ECN on outgoing connection attempts.
         # "2" Enable ECN. When requested by incoming connections, but do not request ECN on outgoing connections.
         # Read: https://www.bufferbloat.net/projects/cerowrt/wiki/Enable_ECN/


############################################################


### irqbalance and Packet Steering ###

IRQBALANCE="no"  # Write: "yes" | "no"
                 ## If you enable or disable it, you need to "reboot" the router for it to take effect.
                 # Help balance the cpu load generated by interrupts across all of a systems cpus and probably increase performance.
                 # The purpose of irqbalance is to distribute hardware interrupts across processors/cores on a multiprocessor/multicore system in order to increase performance.


PACKET_STEERING="no"  # Write: "yes" | "no"
                      ## If you enable or disable it, you need to "reboot" the router for it to take effect.
                      # Enable packet steering across all CPUs. May help or hinder network speed.
                      # It's another (further) approach of trying to equally distribute the load of (network-) packet processing over all available cores.
                      # In theory this should also 'always' help, in practice it can be worse on some devices.
                      # It enables some kind of steering that seems different than what irqbalance does. I'm guessing it sets some of the manual IRQ or TX/RX IRQ assignments.

                      # Enabling packet-steering can go either way, it may improve your throughput or it can worsen your results.
                      # This is hardware (and to come extent protocol-, as in PPPoE vs DHCP vs whatever) dependent, so you need to
                      # test both and compare your speedtests (and CPU load, keep "htop" open over SSH) for both configuration settings.


######################################################################################################################

#########################      #########################      #########################      #########################
### DO NOT EDIT BELOW ###      ### DO NOT EDIT BELOW ###      ### DO NOT EDIT BELOW ###      ### DO NOT EDIT BELOW ###
### DO NOT EDIT BELOW ###      ### DO NOT EDIT BELOW ###      ### DO NOT EDIT BELOW ###      ### DO NOT EDIT BELOW ###
#########################      #########################      #########################      #########################

######################################################################################################################

### Veth method ###

## Suppress warnings about missing public prefix
uci -q get dhcp.odhcpd.loglevel | grep "3" > /dev/null 2>&1 || {
uci set dhcp.odhcpd.loglevel="3"
uci commit && reload_config
}

## Add veth devices
ip link show veth0 > /dev/null 2>&1 || {
ip link add type veth
sleep 10
}
ip link set veth0 up
ip link set veth1 up
ip link set veth1 promisc on
ip link set veth1 master br-lan
ip rule del priority 100 > /dev/null 2>&1
ip route del table 100 > /dev/null 2>&1
ip route add default dev veth0 table 100
ip rule add iif $WAN priority 100 table 100
ip -6 rule del priority 100 > /dev/null 2>&1
ip -6 route del table 100 > /dev/null 2>&1
ip -6 route add default dev veth0 table 100
ip -6 rule add iif $WAN priority 100 table 100

############################################################

### Change default OpenWrt settings ###

## Default qdisc
case $DEFAULT_QDISC in
    fq) DEFAULT_QDISC="fq" ;;
    fq_codel) DEFAULT_QDISC="fq_codel" ;;
    cake) DEFAULT_QDISC="cake" ;;
    *) DEFAULT_QDISC="fq_codel" ;;
esac

## TCP congestion control
case $TCP_CONGESTION_CONTROL in
    reno) TCP_CONGESTION_CONTROL="reno" ;;
    cubic) TCP_CONGESTION_CONTROL="cubic" ;;
    bbr) TCP_CONGESTION_CONTROL="bbr" ;;
    hybla) TCP_CONGESTION_CONTROL="hybla" ;;
    scalable) TCP_CONGESTION_CONTROL="scalable" ;;
    *) TCP_CONGESTION_CONTROL="cubic" ;;
esac

## ECN
case $ECN in
    0) ECN="0" ;;
    1) ECN="1" ;;
    2) ECN="2" ;;
    *) ECN="0" ;;
esac

## Add the settings in "sysctl.conf"
grep "default_qdisc" /etc/sysctl.conf > /dev/null 2>&1 || sed -i "2i net.core.default_qdisc=$DEFAULT_QDISC" /etc/sysctl.conf > /dev/null 2>&1
grep "tcp_congestion_control" /etc/sysctl.conf > /dev/null 2>&1 || sed -i "3i net.ipv4.tcp_congestion_control=$TCP_CONGESTION_CONTROL" /etc/sysctl.conf > /dev/null 2>&1
grep "tcp_ecn" /etc/sysctl.conf > /dev/null 2>&1 || sed -i "4i net.ipv4.tcp_ecn=$ECN" /etc/sysctl.conf > /dev/null 2>&1

## Change the values
grep "default_qdisc" /etc/sysctl.conf | grep "$DEFAULT_QDISC" > /dev/null 2>&1 || sed -i "/default_qdisc/s/=.*/=$DEFAULT_QDISC/" /etc/sysctl.conf > /dev/null 2>&1
grep "tcp_congestion_control" /etc/sysctl.conf | grep "$TCP_CONGESTION_CONTROL" > /dev/null 2>&1 || sed -i "/tcp_congestion_control/s/=.*/=$TCP_CONGESTION_CONTROL/" /etc/sysctl.conf > /dev/null 2>&1
grep "tcp_ecn" /etc/sysctl.conf | grep "$ECN" > /dev/null 2>&1 || sed -i "/tcp_ecn/s/=.*/=$ECN/" /etc/sysctl.conf > /dev/null 2>&1

## Set the values
sysctl -n net.core.default_qdisc | grep "$DEFAULT_QDISC" > /dev/null 2>&1 || sysctl -p > /dev/null 2>&1
sysctl -n net.ipv4.tcp_congestion_control | grep "$TCP_CONGESTION_CONTROL" > /dev/null 2>&1 || sysctl -p > /dev/null 2>&1
sysctl -n net.ipv4.tcp_ecn | grep "$ECN" > /dev/null 2>&1 || sysctl -p > /dev/null 2>&1

############################################################

### irqbalance and Packet Steering ###

## To check if "irqbalance" is installed
CHECK_IRQBALANCE="$(opkg list-installed | grep "irqbalance" | sed 's/ .*//')" > /dev/null 2>&1

## irqbalance
if [ "irqbalance" = "$CHECK_IRQBALANCE" ] && [ "$IRQBALANCE" = "yes" ]; then
    # Enable
    uci -q get irqbalance.irqbalance.enabled | grep "1" > /dev/null 2>&1 || {
    uci -q set irqbalance.irqbalance.enabled="1"
    uci commit && reload_config
    }
elif [ "irqbalance" = "$CHECK_IRQBALANCE" ] && [ "$IRQBALANCE" != "yes" ]; then
    # Disable
    uci -q get irqbalance.irqbalance.enabled | grep "0" > /dev/null 2>&1 || {
    uci -q set irqbalance.irqbalance.enabled="0"
    uci commit && reload_config
    }
fi

## Packet Steering
if [ "$PACKET_STEERING" = "yes" ]; then
    # Enable
    uci -q get network.globals.packet_steering | grep "1" > /dev/null 2>&1 || {
    uci set network.globals.packet_steering="1"
    uci commit && reload_config
    }
elif [ "$PACKET_STEERING" != "yes" ]; then
    # Disable
    uci -q get network.globals.packet_steering > /dev/null 2>&1 && {
    uci del network.globals.packet_steering
    uci commit && reload_config
    }
fi

############################################################

### CAKE settings ###

## SHAPER parameters
case $BANDWIDTH_DOWN in
    "") BANDWIDTH_DOWN_CAKE="" ;;
    *) BANDWIDTH_DOWN_CAKE="bandwidth ${BANDWIDTH_DOWN}mbit" ;;
esac
case $BANDWIDTH_UP in
    "") BANDWIDTH_UP_CAKE="" ;;
    *) BANDWIDTH_UP_CAKE="bandwidth ${BANDWIDTH_UP}mbit" ;;
esac
if [ "$AUTORATE_INGRESS" = "yes" ] && [ "$BANDWIDTH_DOWN" != "0" ] && [ "$BANDWIDTH_DOWN" != "" ]; then
    AUTORATE_INGRESS_CAKE="autorate-ingress"
fi

## OVERHEAD, MPU and LINK COMPENSATION parameters
case $OVERHEAD in
    "") OVERHEAD="" ;;
    *) OVERHEAD="overhead $OVERHEAD" ;;
esac
case $MPU in
    "") MPU="" ;;
    *) MPU="mpu $MPU" ;;
esac
case $LINK_COMPENSATION in
    atm) LINK_COMPENSATION="atm" ;;
    ptm) LINK_COMPENSATION="ptm" ;;
    noatm) LINK_COMPENSATION="noatm" ;;
    *) LINK_COMPENSATION="" ;;
esac

## COMMON LINK PRESETS keywords
case $COMMON_LINK_PRESETS in
    raw) COMMON_LINK_PRESETS="raw" ;;
    conservative) COMMON_LINK_PRESETS="conservative" ;;
    ethernet) COMMON_LINK_PRESETS="ethernet" ;;
    docsis) COMMON_LINK_PRESETS="docsis" ;;
    pppoe-ptm) COMMON_LINK_PRESETS="pppoe-ptm" ;;
    bridged-ptm) COMMON_LINK_PRESETS="bridged-ptm" ;;
    pppoa-vcmux) COMMON_LINK_PRESETS="pppoa-vcmux" ;;
    pppoa-llc) COMMON_LINK_PRESETS="pppoa-llc" ;;
    pppoe-vcmux) COMMON_LINK_PRESETS="pppoe-vcmux" ;;
    pppoe-llcsnap) COMMON_LINK_PRESETS="pppoe-llcsnap" ;;
    bridged-vcmux) COMMON_LINK_PRESETS="bridged-vcmux" ;;
    bridged-llcsnap) COMMON_LINK_PRESETS="bridged-llcsnap" ;;
    ipoa-vcmux) COMMON_LINK_PRESETS="ipoa-vcmux" ;;
    ipoa-llcsnap) COMMON_LINK_PRESETS="ipoa-llcsnap" ;;
    *) COMMON_LINK_PRESETS="" ;;
esac
case $ETHER_VLAN_KEYWORD in
    1) ETHER_VLAN_KEYWORD="ether-vlan" ;;
    2) ETHER_VLAN_KEYWORD="ether-vlan ether-vlan" ;;
    3) ETHER_VLAN_KEYWORD="ether-vlan ether-vlan ether-vlan" ;;
    *) ETHER_VLAN_KEYWORD="" ;;
esac

## PRIORITY QUEUE parameters
case $PRIORITY_QUEUE_INGRESS in
    besteffort) PRIORITY_QUEUE_INGRESS="besteffort" ;;
    diffserv3) PRIORITY_QUEUE_INGRESS="diffserv3" ;;
    diffserv4) PRIORITY_QUEUE_INGRESS="diffserv4" ;;
    diffserv8) PRIORITY_QUEUE_INGRESS="diffserv8" ;;
    *) PRIORITY_QUEUE_INGRESS="" ;;
esac
case $PRIORITY_QUEUE_EGRESS in
    besteffort) PRIORITY_QUEUE_EGRESS="besteffort" ;;
    diffserv3) PRIORITY_QUEUE_EGRESS="diffserv3" ;;
    diffserv4) PRIORITY_QUEUE_EGRESS="diffserv4" ;;
    diffserv8) PRIORITY_QUEUE_EGRESS="diffserv8" ;;
    *) PRIORITY_QUEUE_EGRESS="" ;;
esac

## HOST ISOLATION parameters
if [ "$HOST_ISOLATION" = "yes" ]; then
    HOST_ISOLATION_INGRESS="dual-dsthost"
    HOST_ISOLATION_EGRESS="dual-srchost"
elif [ "$HOST_ISOLATION" != "yes" ]; then
    HOST_ISOLATION_INGRESS=""
    HOST_ISOLATION_EGRESS=""
fi

## NAT parameters
case $NAT_INGRESS in
    yes) NAT_INGRESS="nat" ;;
    no) NAT_INGRESS="nonat" ;;
    *) NAT_INGRESS="" ;;
esac
case $NAT_EGRESS in
    yes) NAT_EGRESS="nat" ;;
    no) NAT_EGRESS="nonat" ;;
    *) NAT_EGRESS="" ;;
esac

## WASH parameters
case $WASH_INGRESS in
    yes) WASH_INGRESS="wash" ;;
    no) WASH_INGRESS="nowash" ;;
    *) WASH_INGRESS="" ;;
esac
case $WASH_EGRESS in
    yes) WASH_EGRESS="wash" ;;
    no) WASH_EGRESS="nowash" ;;
    *) WASH_EGRESS="" ;;
esac

## INGRESS parameter
case $INGRESS_MODE in
    yes) INGRESS_MODE="ingress" ;;
    *) INGRESS_MODE="" ;;
esac

## ACK-FILTER parameters (AUTO)
# Automatically use the "ack-filter" parameter if your up/down bandwidth is at least 1x15 asymmetric
FORMULA="$(awk "BEGIN { a = $BANDWIDTH_DOWN; b = $BANDWIDTH_UP * 14; print (a > b) }")" > /dev/null 2>&1
if [  "$FORMULA" -eq 1 ]; then
    case $ACK_FILTER_EGRESS in
        yes) ACK_FILTER_EGRESS="yes" ;;
        no) ACK_FILTER_EGRESS="no" ;;
        *) ACK_FILTER_EGRESS="yes" ;;
    esac
fi

## ACK-FILTER parameters
case $ACK_FILTER_EGRESS in
    yes) ACK_FILTER_EGRESS="ack-filter" ;;
    no) ACK_FILTER_EGRESS="no-ack-filter" ;;
    *) ACK_FILTER_EGRESS="" ;;
esac

## RTT parameter
case $RTT in
    "") RTT="" ;;
    *) RTT="rtt ${RTT}ms" ;;
esac

############################################################

## Delete the old qdiscs created by the script
tc qdisc del dev veth0 root > /dev/null 2>&1
tc qdisc del dev $WAN root > /dev/null 2>&1

############################################################

### CAKE qdiscs ###

## Inbound / Ingress
if [ "$BANDWIDTH_DOWN" != "" ]; then
    tc qdisc add dev veth0 root cake $BANDWIDTH_DOWN_CAKE $AUTORATE_INGRESS_CAKE $PRIORITY_QUEUE_INGRESS $HOST_ISOLATION_INGRESS $NAT_INGRESS $WASH_INGRESS $INGRESS_MODE $RTT $COMMON_LINK_PRESETS $ETHER_VLAN_KEYWORD $LINK_COMPENSATION $OVERHEAD $MPU $EXTRA_PARAMETERS_INGRESS
fi

## Outbound / Egress
if [ "$BANDWIDTH_UP" != "" ]; then
    tc qdisc add dev $WAN root cake $BANDWIDTH_UP_CAKE $PRIORITY_QUEUE_EGRESS $HOST_ISOLATION_EGRESS $NAT_EGRESS $WASH_EGRESS $ACK_FILTER_EGRESS $RTT $COMMON_LINK_PRESETS $ETHER_VLAN_KEYWORD $LINK_COMPENSATION $OVERHEAD $MPU $EXTRA_PARAMETERS_EGRESS
fi

######################################################################################################################

### Init Script ###

## Check if the file does not exist
if [ ! -f "/etc/init.d/cake" ]; then
cat << "INITSCRIPT" > /etc/init.d/cake
#!/bin/sh /etc/rc.common

USE_PROCD=1

START=99
STOP=99

service_triggers() {
    procd_add_reload_trigger "network"
}

start_service() {
    /etc/init.d/cake enabled || exit 0
    echo start
    procd_open_instance
    procd_set_param command /bin/sh "/root/cake.sh"
    procd_set_param stdout 1
    procd_set_param stderr 1
    procd_close_instance
}

restart() {
    /etc/init.d/cake enabled || exit 0
    echo restart
    /root/cake.sh
}

stop_service() {
    echo stop
    ############################################################

    ### Interface ###
    WAN="$(sed '/WAN=/!d; /sed/d; s/WAN="//; s/".*//' /root/cake.sh)"

    ############################################################

    ## Delete the old qdiscs created by the script
    tc qdisc del dev veth0 root > /dev/null 2>&1
    tc qdisc del dev $WAN root > /dev/null 2>&1

    ############################################################

    ## Delete veth devices
    ip link show veth0 > /dev/null 2>&1 && {
    ip link set veth1 nomaster
    ip link set veth1 promisc off
    ip link set veth1 down
    ip link set veth0 down
    ip link del veth0
    ip rule del priority 100 > /dev/null 2>&1
    ip -6 rule del priority 100 > /dev/null 2>&1
    }

    ############################################################

    ## Restore default OpenWrt settings
    sysctl -w net.core.default_qdisc=fq_codel > /dev/null 2>&1
    sysctl -w net.ipv4.tcp_congestion_control=cubic > /dev/null 2>&1
    sysctl -w net.ipv4.tcp_ecn=0 > /dev/null 2>&1

    ############################################################

    ## Flush all rules from the chains
    nft flush chain inet fw4 dscp_marking_ports_ipv4 > /dev/null 2>&1
    nft flush chain inet fw4 dscp_marking_ports_ipv6 > /dev/null 2>&1
    nft flush chain inet fw4 dscp_marking_ip_addresses_ipv4 > /dev/null 2>&1
    nft flush chain inet fw4 dscp_marking_ip_addresses_ipv6 > /dev/null 2>&1

    ## Delete the rule from the chains
    nft delete rule inet fw4 pre_mangle_forward handle "$(nft -a list ruleset | grep "Wash all ISP DSCP marks to CS1 (IPv4)" | sed 's/.* //')" > /dev/null 2>&1
    nft delete rule inet fw4 pre_mangle_forward handle "$(nft -a list ruleset | grep "Wash all ISP DSCP marks to CS1 (IPv6)" | sed 's/.* //')" > /dev/null 2>&1
    nft delete rule inet fw4 pre_mangle_forward handle "$(nft -a list ruleset | grep "DSCP marking rules for ports (IPv4)" | sed 's/.* //')" > /dev/null 2>&1
    nft delete rule inet fw4 pre_mangle_forward handle "$(nft -a list ruleset | grep "DSCP marking rules for ports (IPv6)" | sed 's/.* //')" > /dev/null 2>&1
    nft delete rule inet fw4 pre_mangle_forward handle "$(nft -a list ruleset | grep "DSCP marking rules for IP addresses (IPv4)" | sed 's/.* //')" > /dev/null 2>&1
    nft delete rule inet fw4 pre_mangle_forward handle "$(nft -a list ruleset | grep "DSCP marking rules for IP addresses (IPv6)" | sed 's/.* //')" > /dev/null 2>&1
    nft delete rule inet fw4 pre_mangle_postrouting handle "$(nft -a list ruleset | grep "DSCP marking rules for ports (IPv4)" | sed 's/.* //')" > /dev/null 2>&1
    nft delete rule inet fw4 pre_mangle_postrouting handle "$(nft -a list ruleset | grep "DSCP marking rules for ports (IPv6)" | sed 's/.* //')" > /dev/null 2>&1
    nft delete rule inet fw4 pre_mangle_postrouting handle "$(nft -a list ruleset | grep "DSCP marking rules for IP addresses (IPv4)" | sed 's/.* //')" > /dev/null 2>&1
    nft delete rule inet fw4 pre_mangle_postrouting handle "$(nft -a list ruleset | grep "DSCP marking rules for IP addresses (IPv6)" | sed 's/.* //')" > /dev/null 2>&1

    ## Delete the chains
    nft delete chain inet fw4 pre_mangle_forward > /dev/null 2>&1
    nft delete chain inet fw4 pre_mangle_postrouting > /dev/null 2>&1
    nft delete chain inet fw4 dscp_marking_ports_ipv4 > /dev/null 2>&1
    nft delete chain inet fw4 dscp_marking_ports_ipv6 > /dev/null 2>&1
    nft delete chain inet fw4 dscp_marking_ip_addresses_ipv4 > /dev/null 2>&1
    nft delete chain inet fw4 dscp_marking_ip_addresses_ipv6 > /dev/null 2>&1

    ############################################################
    exit 0
}

reload_service() {
    start
}
INITSCRIPT
chmod 755 /etc/init.d/cake > /dev/null 2>&1
/etc/init.d/cake enable > /dev/null 2>&1
fi

############################################################

### Hotplug ###

## Check if the file does not exist
if [ ! -f "/etc/hotplug.d/iface/99-cake" ]; then
cat << "HOTPLUG" > /etc/hotplug.d/iface/99-cake
#!/bin/sh

[ "$ACTION" = ifup ] || exit 0
[ "$INTERFACE" = wan ] || [ "$INTERFACE" = lan ] || exit 0

# Ensure that the script is executable by Owner
if [ ! -x "/root/cake.sh" ] || [ ! -x "/etc/init.d/cake" ]; then
    chmod 755 /root/cake.sh
    chmod 755 /etc/init.d/cake
fi

# Check if the init script is enabled to reload the script
/etc/init.d/cake enabled || exit 0

# Reloading the script
logger -t cake "Reloading cake.sh due to $ACTION of $INTERFACE ($DEVICE)"
sleep 10 && /etc/init.d/cake restart
HOTPLUG
fi

######################################################################################################################
echo "############################################################"
echo "                  NOBODY ELSE CAN SAVE YOU"
echo "                     TRUST JESUS TODAY!"
echo "############################################################"
echo ""
echo "As it is written: 'There is none righteous, no, not one'. Romans 3:10"
echo "For all have sinned and come short of the glory of God. Romans 3:23"
echo ""
echo "Therefore, as by one man sin entered into the world, and death by sin, so death passed onto all men, for all have sinned. Romans 5:12"
echo "For the wages of sin is death, but the gift of God is eternal life through Jesus Christ our Lord. Romans 6:23"
echo ""
echo "But God commendeth His love toward us in that, while we were yet sinners, Christ died for us. Romans 5:8"
echo "For 'whosoever shall call upon the name of the Lord shall be saved'. Romans 10:13"
echo ""
echo "Jesus said, 'I am the Way, the Truth, and the Life; no man cometh unto the Father, but by Me.' John 14:6"
echo ""
echo "Behold, I stand at the door and knock. If any man hear My voice and open the door, I will come in to him, and will sup with him, and he with Me. Revelation 3:20"
echo "That if thou shalt confess with thy mouth the Lord Jesus, and shalt believe in thine heart that God hath raised Him from the dead, thou shalt be saved. Romans 10:9"
echo ""
echo "WHAT TO PRAY"
echo "============"
echo "Dear God, I am a sinner and need forgiveness."
echo "I believe that Jesus Christ shed His 'precious blood' and died for my sin."
echo "I am  willing to turn from sin."
echo "I now invite Jesus Christ to come into my heart as my personal Savior. AMEN!"
echo ""
echo "The Lord Jesus is coming for His Church!"
echo "****************************************"
echo "Do not waste your time, repent of your sins and accept Jesus Christ as your Lord and Savior and you and your family will be saved."
echo ""
######################################################################################################################

### Rules settings ###

## Default chain for the rules
case $CHAIN in
    FORWARD) CHAIN="FORWARD" ;;
    POSTROUTING) CHAIN="POSTROUTING" ;;
    *) CHAIN="FORWARD" ;;
esac

## DSCP value for "ICMP" (aka ping)
case $DSCP_ICMP in
    "") DSCP_ICMP="cs0" ;;
    *) DSCP_ICMP="$(printf "%s\n" "$DSCP_ICMP" | awk '{print tolower($0)}')" > /dev/null 2>&1 ;;
esac

## DSCP value for "gaming"
case $DSCP_GAMING in
    "") DSCP_GAMING="cs4" ;;
    *) DSCP_GAMING="$(printf "%s\n" "$DSCP_GAMING" | awk '{print tolower($0)}')" > /dev/null 2>&1 ;;
esac

## DSCP value for "other ports"
case $DSCP_OTHER_PORTS in
    "") DSCP_OTHER_PORTS="cs0" ;;
    *) DSCP_OTHER_PORTS="$(printf "%s\n" "$DSCP_OTHER_PORTS" | awk '{print tolower($0)}')" > /dev/null 2>&1 ;;
esac

## DSCP value for "other static IP addresses"
case $DSCP_OTHER_STATIC_IP in
    "") DSCP_OTHER_STATIC_IP="cs0" ;;
    *) DSCP_OTHER_STATIC_IP="$(printf "%s\n" "$DSCP_OTHER_STATIC_IP" | awk '{print tolower($0)}')" > /dev/null 2>&1 ;;
esac

## Known rules
case $BROADCAST_VIDEO in
    yes) BROADCAST_VIDEO="yes" ;;
    *) BROADCAST_VIDEO="no" ;;
esac
case $GAMING in
    yes) GAMING="yes" ;;
    *) GAMING="no" ;;
esac
case $MULTIMEDIA_CONFERENCING in
    yes) MULTIMEDIA_CONFERENCING="yes" ;;
    *) MULTIMEDIA_CONFERENCING="no" ;;
esac
case $TELEPHONY in
    yes) TELEPHONY="yes" ;;
    *) TELEPHONY="no" ;;
esac

## Comments for the rules
DSCP_ICMP_COMMENT="$(printf "%s\n" "$DSCP_ICMP" | awk '{print toupper($0)}')" > /dev/null 2>&1
DSCP_GAMING_COMMENT="$(printf "%s\n" "$DSCP_GAMING" | awk '{print toupper($0)}')" > /dev/null 2>&1
DSCP_OTHER_PORTS_COMMENT="$(printf "%s\n" "$DSCP_OTHER_PORTS" | awk '{print toupper($0)}')" > /dev/null 2>&1
DSCP_OTHER_STATIC_IP_COMMENT="$(printf "%s\n" "$DSCP_OTHER_STATIC_IP" | awk '{print toupper($0)}')" > /dev/null 2>&1

## Automatically add the IPv6 address
IPV6_ADDRESS="$(printf "%.16s\n" "$(uci -q get network.globals.ula_prefix)")" > /dev/null 2>&1
IPV6_GAME_CONSOLES_STATIC_IP="$(printf "%s\n" "$IPV6_GAME_CONSOLES_STATIC_IP" | sed "s/IPv6::/$IPV6_ADDRESS/g")" > /dev/null 2>&1
IPV6_TORRENTBOX_STATIC_IP="$(printf "%s\n" "$IPV6_TORRENTBOX_STATIC_IP" | sed "s/IPv6::/$IPV6_ADDRESS/g")" > /dev/null 2>&1
IPV6_OTHER_STATIC_IP="$(printf "%s\n" "$IPV6_OTHER_STATIC_IP" | sed "s/IPv6::/$IPV6_ADDRESS/g")" > /dev/null 2>&1

## To check if there is a difference between the settings and the rules
if [ "$CHAIN" = "FORWARD" ]; then
    CHECK_CHAIN="$(grep "jump" /etc/nftables.d/00-rules.nft | sed '1q;d' | grep "    " > /dev/null 2>&1 && echo "FORWARD")" > /dev/null 2>&1
elif [ "$CHAIN" != "FORWARD" ]; then
    CHECK_CHAIN="$(grep "jump" /etc/nftables.d/00-rules.nft | sed '1q;d' | grep "#   " > /dev/null 2>&1 && echo "POSTROUTING")" > /dev/null 2>&1
fi
if [ "$BROADCAST_VIDEO" = "yes" ]; then
    CHECK_BROADCAST_VIDEO="$(grep "Live Streaming ports to" /etc/nftables.d/00-rules.nft | grep "    " > /dev/null 2>&1 && echo "yes")" > /dev/null 2>&1
elif [ "$BROADCAST_VIDEO" != "yes" ]; then
    CHECK_BROADCAST_VIDEO="$(grep "Live Streaming ports to" /etc/nftables.d/00-rules.nft | grep "#   " > /dev/null 2>&1 && echo "no")" > /dev/null 2>&1
fi
if [ "$GAMING" = "yes" ]; then
    CHECK_GAMING="$(grep "Known game ports" /etc/nftables.d/00-rules.nft | grep "    " > /dev/null 2>&1 && echo "yes")" > /dev/null 2>&1
elif [ "$GAMING" != "yes" ]; then
    CHECK_GAMING="$(grep "Known game ports" /etc/nftables.d/00-rules.nft | grep "#   " > /dev/null 2>&1 && echo "no")" > /dev/null 2>&1
fi
if [ "$MULTIMEDIA_CONFERENCING" = "yes" ]; then
    CHECK_MULTIMEDIA_CONFERENCING="$(grep "Known video conferencing ports to" /etc/nftables.d/00-rules.nft | grep "    " > /dev/null 2>&1 && echo "yes")" > /dev/null 2>&1
elif [ "$MULTIMEDIA_CONFERENCING" != "yes" ]; then
    CHECK_MULTIMEDIA_CONFERENCING="$(grep "Known video conferencing ports to" /etc/nftables.d/00-rules.nft | grep "#   " > /dev/null 2>&1 && echo "no")" > /dev/null 2>&1
fi
if [ "$TELEPHONY" = "yes" ]; then
    CHECK_TELEPHONY="$(grep "Known VoIP and VoWiFi ports to" /etc/nftables.d/00-rules.nft | grep "    " > /dev/null 2>&1 && echo "yes")" > /dev/null 2>&1
elif [ "$TELEPHONY" != "yes" ]; then
    CHECK_TELEPHONY="$(grep "Known VoIP and VoWiFi ports to" /etc/nftables.d/00-rules.nft | grep "#   " > /dev/null 2>&1 && echo "no")" > /dev/null 2>&1
fi
CHECK_DSCP_ICMP="$(sed '/ICMP (aka ping) to/!d; s/.*set //; s/ comment.*//' /etc/nftables.d/00-rules.nft)" > /dev/null 2>&1
CHECK_DSCP_GAMING="$(sed '/Game ports to/!d; s/.*set //; s/ comment.*//' /etc/nftables.d/00-rules.nft | sed '1q;d')" > /dev/null 2>&1
CHECK_TCP_SRC_GAME_PORTS="$(sed '/Game ports to/!d; s/.*{ //; s/ }.*//' /etc/nftables.d/00-rules.nft | sed '1q;d')" > /dev/null 2>&1
CHECK_TCP_DST_GAME_PORTS="$(sed '/Game ports to/!d; s/.*{ //; s/ }.*//' /etc/nftables.d/00-rules.nft | sed '2q;d')" > /dev/null 2>&1
CHECK_UDP_SRC_GAME_PORTS="$(sed '/Game ports to/!d; s/.*{ //; s/ }.*//' /etc/nftables.d/00-rules.nft | sed '3q;d')" > /dev/null 2>&1
CHECK_UDP_DST_GAME_PORTS="$(sed '/Game ports to/!d; s/.*{ //; s/ }.*//' /etc/nftables.d/00-rules.nft | sed '4q;d')" > /dev/null 2>&1
CHECK_TCP_SRC_BULK_PORTS="$(sed '/Bulk ports to/!d; s/.*{ //; s/ }.*//' /etc/nftables.d/00-rules.nft | sed '1q;d')" > /dev/null 2>&1
CHECK_TCP_DST_BULK_PORTS="$(sed '/Bulk ports to/!d; s/.*{ //; s/ }.*//' /etc/nftables.d/00-rules.nft | sed '2q;d')" > /dev/null 2>&1
CHECK_UDP_SRC_BULK_PORTS="$(sed '/Bulk ports to/!d; s/.*{ //; s/ }.*//' /etc/nftables.d/00-rules.nft | sed '3q;d')" > /dev/null 2>&1
CHECK_UDP_DST_BULK_PORTS="$(sed '/Bulk ports to/!d; s/.*{ //; s/ }.*//' /etc/nftables.d/00-rules.nft | sed '4q;d')" > /dev/null 2>&1
CHECK_DSCP_OTHER_PORTS="$(sed '/Other ports to/!d; s/.*set //; s/ comment.*//' /etc/nftables.d/00-rules.nft | sed '1q;d')" > /dev/null 2>&1
CHECK_TCP_SRC_OTHER_PORTS="$(sed '/Other ports to/!d; s/.*{ //; s/ }.*//' /etc/nftables.d/00-rules.nft | sed '1q;d')" > /dev/null 2>&1
CHECK_TCP_DST_OTHER_PORTS="$(sed '/Other ports to/!d; s/.*{ //; s/ }.*//' /etc/nftables.d/00-rules.nft | sed '2q;d')" > /dev/null 2>&1
CHECK_UDP_SRC_OTHER_PORTS="$(sed '/Other ports to/!d; s/.*{ //; s/ }.*//' /etc/nftables.d/00-rules.nft | sed '3q;d')" > /dev/null 2>&1
CHECK_UDP_DST_OTHER_PORTS="$(sed '/Other ports to/!d; s/.*{ //; s/ }.*//' /etc/nftables.d/00-rules.nft | sed '4q;d')" > /dev/null 2>&1
CHECK_IPV4_GAME_CONSOLES_STATIC_IP="$(sed '/Game consoles to /!d; s/.*daddr { //; s/ } meta.*//' /etc/nftables.d/00-rules.nft | sed '1q;d')" > /dev/null 2>&1
CHECK_IPV6_GAME_CONSOLES_STATIC_IP="$(sed '/Game consoles to /!d; s/.*daddr { //; s/ } meta.*//' /etc/nftables.d/00-rules.nft | sed '3q;d')" > /dev/null 2>&1
CHECK_IPV4_TORRENTBOX_STATIC_IP="$(sed '/TorrentBox to /!d; s/.*{ //; s/ }.*//' /etc/nftables.d/00-rules.nft | sed '1q;d')" > /dev/null 2>&1
CHECK_IPV6_TORRENTBOX_STATIC_IP="$(sed '/TorrentBox to /!d; s/.*{ //; s/ }.*//' /etc/nftables.d/00-rules.nft | sed '3q;d')" > /dev/null 2>&1
CHECK_DSCP_OTHER_STATIC_IP="$(sed '/Other static IP addresses to/!d; s/.*set //; s/ comment.*//' /etc/nftables.d/00-rules.nft | sed '1q;d')" > /dev/null 2>&1
CHECK_IPV4_OTHER_STATIC_IP="$(sed '/Other static IP addresses to /!d; s/.*{ //; s/ }.*//' /etc/nftables.d/00-rules.nft | sed '1q;d')" > /dev/null 2>&1
CHECK_IPV6_OTHER_STATIC_IP="$(sed '/Other static IP addresses to /!d; s/.*{ //; s/ }.*//' /etc/nftables.d/00-rules.nft | sed '3q;d')" > /dev/null 2>&1

############################################################

### Rules ###

if [ "$CHAIN" != "$CHECK_CHAIN" ] || \
   [ "$DSCP_ICMP" != "$CHECK_DSCP_ICMP" ] || \
   [ "$DSCP_GAMING" != "$CHECK_DSCP_GAMING" ] || \
   [ "$BROADCAST_VIDEO" != "$CHECK_BROADCAST_VIDEO" ] || \
   [ "$GAMING" != "$CHECK_GAMING" ] || \
   [ "$MULTIMEDIA_CONFERENCING" != "$CHECK_MULTIMEDIA_CONFERENCING" ] || \
   [ "$TELEPHONY" != "$CHECK_TELEPHONY" ] || \
   [ "$TCP_SRC_GAME_PORTS" != "$CHECK_TCP_SRC_GAME_PORTS" ] || \
   [ "$TCP_DST_GAME_PORTS" != "$CHECK_TCP_DST_GAME_PORTS" ] || \
   [ "$UDP_SRC_GAME_PORTS" != "$CHECK_UDP_SRC_GAME_PORTS" ] || \
   [ "$UDP_DST_GAME_PORTS" != "$CHECK_UDP_DST_GAME_PORTS" ] || \
   [ "$TCP_SRC_BULK_PORTS" != "$CHECK_TCP_SRC_BULK_PORTS" ] || \
   [ "$TCP_DST_BULK_PORTS" != "$CHECK_TCP_DST_BULK_PORTS" ] || \
   [ "$UDP_SRC_BULK_PORTS" != "$CHECK_UDP_SRC_BULK_PORTS" ] || \
   [ "$UDP_DST_BULK_PORTS" != "$CHECK_UDP_DST_BULK_PORTS" ] || \
   [ "$DSCP_OTHER_PORTS" != "$CHECK_DSCP_OTHER_PORTS" ] || \
   [ "$TCP_SRC_OTHER_PORTS" != "$CHECK_TCP_SRC_OTHER_PORTS" ] || \
   [ "$TCP_DST_OTHER_PORTS" != "$CHECK_TCP_DST_OTHER_PORTS" ] || \
   [ "$UDP_SRC_OTHER_PORTS" != "$CHECK_UDP_SRC_OTHER_PORTS" ] || \
   [ "$UDP_DST_OTHER_PORTS" != "$CHECK_UDP_DST_OTHER_PORTS" ] || \
   [ "$IPV4_GAME_CONSOLES_STATIC_IP" != "$CHECK_IPV4_GAME_CONSOLES_STATIC_IP" ] || \
   [ "$IPV6_GAME_CONSOLES_STATIC_IP" != "$CHECK_IPV6_GAME_CONSOLES_STATIC_IP" ] || \
   [ "$IPV4_TORRENTBOX_STATIC_IP" != "$CHECK_IPV4_TORRENTBOX_STATIC_IP" ] || \
   [ "$IPV6_TORRENTBOX_STATIC_IP" != "$CHECK_IPV6_TORRENTBOX_STATIC_IP" ] || \
   [ "$DSCP_OTHER_STATIC_IP" != "$CHECK_DSCP_OTHER_STATIC_IP" ] || \
   [ "$IPV4_OTHER_STATIC_IP" != "$CHECK_IPV4_OTHER_STATIC_IP" ] || \
   [ "$IPV6_OTHER_STATIC_IP" != "$CHECK_IPV6_OTHER_STATIC_IP" ]; then

cat << RULES > /tmp/00-rules.nft
### DSCP marking rules ###

chain pre_mangle_forward {
    type filter hook forward priority mangle -1; policy accept;
    ## Wash all ISP DSCP marks from ingress traffic and set these rules as the default for unmarked traffic
    meta nfproto ipv4 counter ip dscp set cs1 comment "Wash all ISP DSCP marks to CS1 (IPv4)"
    meta nfproto ipv6 counter ip6 dscp set cs1 comment "Wash all ISP DSCP marks to CS1 (IPv6)"

    ## Arrange ruleset
    meta nfproto ipv4 jump dscp_marking_ports_ipv4 comment "DSCP marking rules for ports (IPv4)"
    meta nfproto ipv6 jump dscp_marking_ports_ipv6 comment "DSCP marking rules for ports (IPv6)"
    meta nfproto ipv4 jump dscp_marking_ip_addresses_ipv4 comment "DSCP marking rules for IP addresses (IPv4)"
    meta nfproto ipv6 jump dscp_marking_ip_addresses_ipv6 comment "DSCP marking rules for IP addresses (IPv6)"
}

chain pre_mangle_postrouting {
    type filter hook postrouting priority mangle -1; policy accept;
    ## Arrange ruleset
    meta nfproto ipv4 jump dscp_marking_ports_ipv4 comment "DSCP marking rules for ports (IPv4)"
    meta nfproto ipv6 jump dscp_marking_ports_ipv6 comment "DSCP marking rules for ports (IPv6)"
    meta nfproto ipv4 jump dscp_marking_ip_addresses_ipv4 comment "DSCP marking rules for IP addresses (IPv4)"
    meta nfproto ipv6 jump dscp_marking_ip_addresses_ipv6 comment "DSCP marking rules for IP addresses (IPv6)"
}

chain dscp_marking_ports_ipv4 {
    ## Port rules (IPv4) ##

    # ICMP (aka ping)
    meta l4proto icmp counter ip dscp set $DSCP_ICMP comment "ICMP (aka ping) to $DSCP_ICMP_COMMENT"

    # SSH, NTP and DNS
    meta nfproto ipv4 tcp sport { 22, 53, 5353 } counter ip dscp set cs2 comment "SSH and DNS to CS2 (TCP)"
    meta nfproto ipv4 tcp dport { 22, 53, 5353 } counter ip dscp set cs2 comment "SSH and DNS to CS2 (TCP)"
    meta nfproto ipv4 udp sport { 123, 53, 5353 } counter ip dscp set cs2 comment "NTP and DNS to CS2 (UDP)"
    meta nfproto ipv4 udp dport { 123, 53, 5353 } counter ip dscp set cs2 comment "NTP and DNS to CS2 (UDP)"

    # DNS over TLS (DoT)
    meta nfproto ipv4 tcp sport 853 counter ip dscp set af41 comment "DNS over TLS to AF41 (TCP)"
    meta nfproto ipv4 tcp dport 853 counter ip dscp set af41 comment "DNS over TLS to AF41 (TCP)"
    meta nfproto ipv4 udp sport 853 counter ip dscp set af41 comment "DNS over TLS to AF41 (UDP)"
    meta nfproto ipv4 udp dport 853 counter ip dscp set af41 comment "DNS over TLS to AF41 (UDP)"

    # HTTP/HTTPS and QUIC
    meta nfproto ipv4 meta l4proto { tcp, udp } th sport { 80, 443 } meta length 0-575 counter ip dscp set af41 comment "Prioritize ingress light browsing (text/live chat/code?) and VoIP (these are the fallback ports) to AF41 (TCP and UDP)"
    meta nfproto ipv4 meta l4proto { tcp, udp } th dport { 80, 443 } meta length 0-77 counter ip dscp set cs0 comment "Prioritize egress smaller packets (like ACKs, SYN) to CS0 (TCP and UDP) - Downloads in general agressively max out this class"
    meta nfproto ipv4 meta l4proto { tcp, udp } th dport { 80, 443 } meta length 77-575 limit rate 230/second counter ip dscp set af41 comment "Prioritize egress light browsing (text/live chat/code?) and VoIP (these are the fallback ports) to AF41 (TCP and UDP)"
    meta nfproto ipv4 meta l4proto { tcp, udp } th dport { 80, 443 } meta length 77-575 limit rate over 230/second counter ip dscp set cs0 comment "Deprioritize egress traffic of packet lengths between 77 and 575 bytes that have more than 230 pps to CS0 (TCP and UDP)"
    meta nfproto ipv4 meta l4proto { tcp, udp } th sport { 80, 443 } meta length > 575 ct bytes 0-1536000 counter ip dscp set af31 comment "Download transfers with less than 1.5 MB to AF31 (TCP and UDP) - Web browsing and games lobby"
    meta nfproto ipv4 meta l4proto { tcp, udp } th sport { 80, 443 } meta length > 575 ct bytes ge 1536000 counter ip dscp set cs0 comment "Download transfers with more than 1.5 MB to CS0 (TCP and UDP)"

    # Live Streaming ports for YouTube Live, Twitch, Vimeo and LinkedIn Live
    meta nfproto ipv4 tcp sport { 1935-1936, 2396, 2935 } counter ip dscp set cs3 comment "Live Streaming ports to CS3 (TCP)"
    meta nfproto ipv4 tcp dport { 1935-1936, 2396, 2935 } counter ip dscp set cs3 comment "Live Streaming ports to CS3 (TCP)"

    # Xbox, PlayStation, Call of Duty, FIFA, Minecraft and Supercell Games
    meta nfproto ipv4 tcp sport { 3074, 3478-3480, 3075-3076, 3659, 25565, 9339 } counter ip dscp set $DSCP_GAMING comment "Known game ports and game consoles ports to $DSCP_GAMING_COMMENT (TCP)"
    meta nfproto ipv4 tcp dport { 3074, 3478-3480, 3075-3076, 3659, 25565, 9339 } counter ip dscp set $DSCP_GAMING comment "Known game ports and game consoles ports to $DSCP_GAMING_COMMENT (TCP)"
    meta nfproto ipv4 udp sport { 88, 3074, 3544, 3075-3079, 3658-3659, 19132-19133, 25565, 9339 } counter ip dscp set $DSCP_GAMING comment "Known game ports and game consoles ports to $DSCP_GAMING_COMMENT (UDP)"
    meta nfproto ipv4 udp dport { 88, 3074, 3544, 3075-3079, 3658-3659, 19132-19133, 25565, 9339 } counter ip dscp set $DSCP_GAMING comment "Known game ports and game consoles ports to $DSCP_GAMING_COMMENT (UDP)"

    # Zoom, Microsoft Teams, Skype, FaceTime, GoToMeeting, Webex Meeting, Jitsi Meet, Google Meet and TeamViewer
    meta nfproto ipv4 tcp sport { 8801-8802, 5004, 5349, 5938 } counter ip dscp set af41 comment "Known video conferencing ports to AF41 (TCP)"
    meta nfproto ipv4 tcp dport { 8801-8802, 5004, 5349, 5938 } counter ip dscp set af41 comment "Known video conferencing ports to AF41 (TCP)"
    meta nfproto ipv4 udp sport { 3478-3497, 8801-8810, 16384-16387, 16393-16402, 1853, 8200, 9000, 10000, 19302-19309, 5938 } counter ip dscp set af41 comment "Known video conferencing ports to AF41 (UDP)"
    meta nfproto ipv4 udp dport { 3478-3497, 8801-8810, 16384-16387, 16393-16402, 1853, 8200, 9000, 10000, 19302-19309, 5938 } counter ip dscp set af41 comment "Known video conferencing ports to AF41 (UDP)"

    # Voice over Internet Protocol (VoIP) and Voice over WiFi or WiFi Calling (VoWiFi)
    meta nfproto ipv4 tcp sport { 5060-5061 } counter ip dscp set ef comment "Known VoIP and VoWiFi ports to EF (TCP)"
    meta nfproto ipv4 tcp dport { 5060-5061 } counter ip dscp set ef comment "Known VoIP and VoWiFi ports to EF (TCP)"
    meta nfproto ipv4 udp sport { 5060-5061, 500, 4500 } counter ip dscp set ef comment "Known VoIP and VoWiFi ports to EF (UDP)"
    meta nfproto ipv4 udp dport { 5060-5061, 500, 4500 } counter ip dscp set ef comment "Known VoIP and VoWiFi ports to EF (UDP)"

    # Packet mark for Usenet, BitTorrent and "custom bulk ports" to be excluded
    meta nfproto ipv4 tcp sport { 119, 563, 6881-7000, 9000, 28221, 30301, 41952, 49160, 51413, $TCP_SRC_BULK_PORTS } ip dscp cs1 counter meta mark set 75 comment "Packet mark for Usenet, BitTorrent and custom bulk ports to be excluded (TCP)"
    meta nfproto ipv4 tcp dport { 119, 563, 6881-7000, 9000, 28221, 30301, 41952, 49160, 51413, $TCP_DST_BULK_PORTS } ip dscp cs1 counter meta mark set 75 comment "Packet mark for Usenet, BitTorrent and custom bulk ports to be excluded (TCP)"
    meta nfproto ipv4 udp sport { 6771, 6881-7000, 28221, 30301, 41952, 49160, 51413, $UDP_SRC_BULK_PORTS } ip dscp cs1 counter meta mark set 75 comment "Packet mark for Usenet, BitTorrent and custom bulk ports to be excluded (UDP)"
    meta nfproto ipv4 udp dport { 6771, 6881-7000, 28221, 30301, 41952, 49160, 51413, $UDP_DST_BULK_PORTS } ip dscp cs1 counter meta mark set 75 comment "Packet mark for Usenet, BitTorrent and custom bulk ports to be excluded (UDP)"

    # Unmarked TCP traffic
    meta nfproto ipv4 tcp sport != { 80, 443, 8080, 1935-1936, 2396, 2935 } tcp dport != { 80, 443, 8080, 1935-1936, 2396, 2935 } meta mark != 75 meta length 0-575 ip dscp cs1 counter meta mark set 80 comment "Packet mark for unmarked TCP traffic of packet lengths between 0 and 575 bytes"
    meta nfproto ipv4 meta l4proto tcp meta length 0-575 ct direction reply meta mark 80 counter ip dscp set af41 comment "Prioritize ingress unmarked traffic of packet lengths between 0 and 575 bytes to AF41 (TCP)"
    meta nfproto ipv4 meta l4proto tcp meta length 0-77 ct direction original meta mark 80 counter ip dscp set cs0 comment "Prioritize egress unmarked traffic of packet lengths between 0 and 77 bytes to CS0 (TCP)"
    meta nfproto ipv4 meta l4proto tcp meta length 77-575 limit rate 230/second ct direction original meta mark 80 counter ip dscp set af41 comment "Prioritize egress unmarked traffic of packet lengths between 77 and 575 bytes to AF41 (TCP)"
    meta nfproto ipv4 meta l4proto tcp meta length 77-575 limit rate over 230/second ct direction original meta mark 80 counter ip dscp set cs0 comment "Deprioritize egress unmarked traffic of packet lengths between 77 and 575 bytes that have more than 230 pps to CS0 (TCP)"

    # Unmarked UDP traffic (Some games also tend to use really tiny packets on upload side (same range as ACKs))
    meta nfproto ipv4 udp sport != { 80, 443 } udp dport != { 80, 443 } meta mark != 75 meta length 0-1256 limit rate over 230/second burst 100 packets ip dscp cs1 counter meta mark set 85 comment "Packet mark for unmarked UDP traffic of packet lengths between 0 and 1256 bytes that have more than 230 pps"
    meta nfproto ipv4 meta l4proto udp numgen random mod 1000 < 5 meta mark 85 counter meta mark set 0 comment "0.5% probability of unmark a packet that go over 230 pps to be prioritized to $DSCP_GAMING_COMMENT (UDP)"
    meta nfproto ipv4 meta l4proto udp meta length 0-77 ct direction reply meta mark 85 counter ip dscp set af41 comment "Prioritize ingress unmarked traffic of packet lengths between 0 and 77 bytes that have more than 230 pps to AF41 (UDP)"
    meta nfproto ipv4 meta l4proto udp meta length 0-77 ct direction original meta mark 85 counter ip dscp set cs0 comment "Prioritize egress unmarked traffic of packet lengths between 0 and 77 bytes that have more than 230 pps to CS0 (UDP)"
    meta nfproto ipv4 udp sport != { 80, 443 } udp dport != { 80, 443 } meta mark != { 75, 85 } meta length 0-1256 ip dscp cs1 counter ip dscp set $DSCP_GAMING comment "Prioritize unmarked traffic of packet lengths between 0 and 1256 bytes that have less than 230 pps to $DSCP_GAMING_COMMENT (UDP) - Gaming & VoIP"

    ## Custom port rules (IPv4) ##

    # Game ports - Used by games
    meta nfproto ipv4 tcp sport { $TCP_SRC_GAME_PORTS } counter ip dscp set $DSCP_GAMING comment "Game ports to $DSCP_GAMING_COMMENT (TCP)"
    meta nfproto ipv4 tcp dport { $TCP_DST_GAME_PORTS } counter ip dscp set $DSCP_GAMING comment "Game ports to $DSCP_GAMING_COMMENT (TCP)"
    meta nfproto ipv4 udp sport { $UDP_SRC_GAME_PORTS } counter ip dscp set $DSCP_GAMING comment "Game ports to $DSCP_GAMING_COMMENT (UDP)"
    meta nfproto ipv4 udp dport { $UDP_DST_GAME_PORTS } counter ip dscp set $DSCP_GAMING comment "Game ports to $DSCP_GAMING_COMMENT (UDP)"

    # Bulk ports - Used for 'bulk traffic' such as "BitTorrent"
    meta nfproto ipv4 tcp sport { $TCP_SRC_BULK_PORTS } counter ip dscp set cs1 comment "Bulk ports to CS1 (TCP)"
    meta nfproto ipv4 tcp dport { $TCP_DST_BULK_PORTS } counter ip dscp set cs1 comment "Bulk ports to CS1 (TCP)"
    meta nfproto ipv4 udp sport { $UDP_SRC_BULK_PORTS } counter ip dscp set cs1 comment "Bulk ports to CS1 (UDP)"
    meta nfproto ipv4 udp dport { $UDP_DST_BULK_PORTS } counter ip dscp set cs1 comment "Bulk ports to CS1 (UDP)"

    # Other ports [OPTIONAL] - Mark wherever you want
    meta nfproto ipv4 tcp sport { $TCP_SRC_OTHER_PORTS } counter ip dscp set $DSCP_OTHER_PORTS comment "Other ports to $DSCP_OTHER_PORTS_COMMENT (TCP)"
    meta nfproto ipv4 tcp dport { $TCP_DST_OTHER_PORTS } counter ip dscp set $DSCP_OTHER_PORTS comment "Other ports to $DSCP_OTHER_PORTS_COMMENT (TCP)"
    meta nfproto ipv4 udp sport { $UDP_SRC_OTHER_PORTS } counter ip dscp set $DSCP_OTHER_PORTS comment "Other ports to $DSCP_OTHER_PORTS_COMMENT (UDP)"
    meta nfproto ipv4 udp dport { $UDP_DST_OTHER_PORTS } counter ip dscp set $DSCP_OTHER_PORTS comment "Other ports to $DSCP_OTHER_PORTS_COMMENT (UDP)"
}

chain dscp_marking_ports_ipv6 {
    ## Port rules (IPv6) ##

    # ICMPv6 (aka ping)
    meta l4proto ipv6-icmp counter ip6 dscp set $DSCP_ICMP comment "ICMPv6 (aka ping) to $DSCP_ICMP_COMMENT"

    # SSH, NTP and DNS
    meta nfproto ipv6 tcp sport { 22, 53, 5353 } counter ip6 dscp set cs2 comment "SSH and DNS to CS2 (TCP)"
    meta nfproto ipv6 tcp dport { 22, 53, 5353 } counter ip6 dscp set cs2 comment "SSH and DNS to CS2 (TCP)"
    meta nfproto ipv6 udp sport { 123, 53, 5353 } counter ip6 dscp set cs2 comment "NTP and DNS to CS2 (UDP)"
    meta nfproto ipv6 udp dport { 123, 53, 5353 } counter ip6 dscp set cs2 comment "NTP and DNS to CS2 (UDP)"

    # DNS over TLS (DoT)
    meta nfproto ipv6 tcp sport 853 counter ip6 dscp set af41 comment "DNS over TLS to AF41 (TCP)"
    meta nfproto ipv6 tcp dport 853 counter ip6 dscp set af41 comment "DNS over TLS to AF41 (TCP)"
    meta nfproto ipv6 udp sport 853 counter ip6 dscp set af41 comment "DNS over TLS to AF41 (UDP)"
    meta nfproto ipv6 udp dport 853 counter ip6 dscp set af41 comment "DNS over TLS to AF41 (UDP)"

    # HTTP/HTTPS and QUIC
    meta nfproto ipv6 meta l4proto { tcp, udp } th sport { 80, 443 } meta length 0-575 counter ip6 dscp set af41 comment "Prioritize ingress light browsing (text/live chat/code?) and VoIP (these are the fallback ports) to AF41 (TCP and UDP)"
    meta nfproto ipv6 meta l4proto { tcp, udp } th dport { 80, 443 } meta length 0-77 counter ip6 dscp set cs0 comment "Prioritize egress smaller packets (like ACKs, SYN) to CS0 (TCP and UDP) - Downloads in general agressively max out this class"
    meta nfproto ipv6 meta l4proto { tcp, udp } th dport { 80, 443 } meta length 77-575 limit rate 230/second counter ip6 dscp set af41 comment "Prioritize egress light browsing (text/live chat/code?) and VoIP (these are the fallback ports) to AF41 (TCP and UDP)"
    meta nfproto ipv6 meta l4proto { tcp, udp } th dport { 80, 443 } meta length 77-575 limit rate over 230/second counter ip6 dscp set cs0 comment "Deprioritize egress traffic of packet lengths between 77 and 575 bytes that have more than 230 pps to CS0 (TCP and UDP)"
    meta nfproto ipv6 meta l4proto { tcp, udp } th sport { 80, 443 } meta length > 575 ct bytes 0-1536000 counter ip6 dscp set af31 comment "Download transfers with less than 1.5 MB to AF31 (TCP and UDP) - Web browsing and games lobby"
    meta nfproto ipv6 meta l4proto { tcp, udp } th sport { 80, 443 } meta length > 575 ct bytes ge 1536000 counter ip6 dscp set cs0 comment "Download transfers with more than 1.5 MB to CS0 (TCP and UDP)"

    # Live Streaming ports for YouTube Live, Twitch, Vimeo and LinkedIn Live
    meta nfproto ipv6 tcp sport { 1935-1936, 2396, 2935 } counter ip6 dscp set cs3 comment "Live Streaming ports to CS3 (TCP)"
    meta nfproto ipv6 tcp dport { 1935-1936, 2396, 2935 } counter ip6 dscp set cs3 comment "Live Streaming ports to CS3 (TCP)"

    # Xbox, PlayStation, Call of Duty, FIFA, Minecraft and Supercell Games
    meta nfproto ipv6 tcp sport { 3074, 3478-3480, 3075-3076, 3659, 25565, 9339 } counter ip6 dscp set $DSCP_GAMING comment "Known game ports and game consoles ports to $DSCP_GAMING_COMMENT (TCP)"
    meta nfproto ipv6 tcp dport { 3074, 3478-3480, 3075-3076, 3659, 25565, 9339 } counter ip6 dscp set $DSCP_GAMING comment "Known game ports and game consoles ports to $DSCP_GAMING_COMMENT (TCP)"
    meta nfproto ipv6 udp sport { 88, 3074, 3544, 3075-3079, 3658-3659, 19132-19133, 25565, 9339 } counter ip6 dscp set $DSCP_GAMING comment "Known game ports and game consoles ports to $DSCP_GAMING_COMMENT (UDP)"
    meta nfproto ipv6 udp dport { 88, 3074, 3544, 3075-3079, 3658-3659, 19132-19133, 25565, 9339 } counter ip6 dscp set $DSCP_GAMING comment "Known game ports and game consoles ports to $DSCP_GAMING_COMMENT (UDP)"

    # Zoom, Microsoft Teams, Skype, FaceTime, GoToMeeting, Webex Meeting, Jitsi Meet, Google Meet and TeamViewer
    meta nfproto ipv6 tcp sport { 8801-8802, 5004, 5349, 5938 } counter ip6 dscp set af41 comment "Known video conferencing ports to AF41 (TCP)"
    meta nfproto ipv6 tcp dport { 8801-8802, 5004, 5349, 5938 } counter ip6 dscp set af41 comment "Known video conferencing ports to AF41 (TCP)"
    meta nfproto ipv6 udp sport { 3478-3497, 8801-8810, 16384-16387, 16393-16402, 1853, 8200, 9000, 10000, 19302-19309, 5938 } counter ip6 dscp set af41 comment "Known video conferencing ports to AF41 (UDP)"
    meta nfproto ipv6 udp dport { 3478-3497, 8801-8810, 16384-16387, 16393-16402, 1853, 8200, 9000, 10000, 19302-19309, 5938 } counter ip6 dscp set af41 comment "Known video conferencing ports to AF41 (UDP)"

    # Voice over Internet Protocol (VoIP) and Voice over WiFi or WiFi Calling (VoWiFi)
    meta nfproto ipv6 tcp sport { 5060-5061 } counter ip6 dscp set ef comment "Known VoIP and VoWiFi ports to EF (TCP)"
    meta nfproto ipv6 tcp dport { 5060-5061 } counter ip6 dscp set ef comment "Known VoIP and VoWiFi ports to EF (TCP)"
    meta nfproto ipv6 udp sport { 5060-5061, 500, 4500 } counter ip6 dscp set ef comment "Known VoIP and VoWiFi ports to EF (UDP)"
    meta nfproto ipv6 udp dport { 5060-5061, 500, 4500 } counter ip6 dscp set ef comment "Known VoIP and VoWiFi ports to EF (UDP)"

    # Packet mark for Usenet, BitTorrent and "custom bulk ports" to be excluded
    meta nfproto ipv6 tcp sport { 119, 563, 6881-7000, 9000, 28221, 30301, 41952, 49160, 51413, $TCP_SRC_BULK_PORTS } ip6 dscp cs1 counter meta mark set 75 comment "Packet mark for Usenet, BitTorrent and custom bulk ports to be excluded (TCP)"
    meta nfproto ipv6 tcp dport { 119, 563, 6881-7000, 9000, 28221, 30301, 41952, 49160, 51413, $TCP_DST_BULK_PORTS } ip6 dscp cs1 counter meta mark set 75 comment "Packet mark for Usenet, BitTorrent and custom bulk ports to be excluded (TCP)"
    meta nfproto ipv6 udp sport { 6771, 6881-7000, 28221, 30301, 41952, 49160, 51413, $UDP_SRC_BULK_PORTS } ip6 dscp cs1 counter meta mark set 75 comment "Packet mark for Usenet, BitTorrent and custom bulk ports to be excluded (UDP)"
    meta nfproto ipv6 udp dport { 6771, 6881-7000, 28221, 30301, 41952, 49160, 51413, $UDP_DST_BULK_PORTS } ip6 dscp cs1 counter meta mark set 75 comment "Packet mark for Usenet, BitTorrent and custom bulk ports to be excluded (UDP)"

    # Unmarked TCP traffic
    meta nfproto ipv6 tcp sport != { 80, 443, 8080, 1935-1936, 2396, 2935 } tcp dport != { 80, 443, 8080, 1935-1936, 2396, 2935 } meta mark != 75 meta length 0-575 ip6 dscp cs1 counter meta mark set 80 comment "Packet mark for unmarked TCP traffic of packet lengths between 0 and 575 bytes"
    meta nfproto ipv6 meta l4proto tcp meta length 0-575 ct direction reply meta mark 80 counter ip6 dscp set af41 comment "Prioritize ingress unmarked traffic of packet lengths between 0 and 575 bytes to AF41 (TCP)"
    meta nfproto ipv6 meta l4proto tcp meta length 0-77 ct direction original meta mark 80 counter ip6 dscp set cs0 comment "Prioritize egress unmarked traffic of packet lengths between 0 and 77 bytes to CS0 (TCP)"
    meta nfproto ipv6 meta l4proto tcp meta length 77-575 limit rate 230/second ct direction original meta mark 80 counter ip6 dscp set af41 comment "Prioritize egress unmarked traffic of packet lengths between 77 and 575 bytes to AF41 (TCP)"
    meta nfproto ipv6 meta l4proto tcp meta length 77-575 limit rate over 230/second ct direction original meta mark 80 counter ip6 dscp set cs0 comment "Deprioritize egress unmarked traffic of packet lengths between 77 and 575 bytes that have more than 230 pps to CS0 (TCP)"

    # Unmarked UDP traffic (Some games also tend to use really tiny packets on upload side (same range as ACKs))
    meta nfproto ipv6 udp sport != { 80, 443 } udp dport != { 80, 443 } meta mark != 75 meta length 0-1256 limit rate over 230/second burst 100 packets ip6 dscp cs1 counter meta mark set 85 comment "Packet mark for unmarked UDP traffic of packet lengths between 0 and 1256 bytes that have more than 230 pps"
    meta nfproto ipv6 meta l4proto udp numgen random mod 1000 < 5 meta mark 85 counter meta mark set 0 comment "0.5% probability of unmark a packet that go over 230 pps to be prioritized to $DSCP_GAMING_COMMENT (UDP)"
    meta nfproto ipv6 meta l4proto udp meta length 0-77 ct direction reply meta mark 85 counter ip6 dscp set af41 comment "Prioritize ingress unmarked traffic of packet lengths between 0 and 77 bytes that have more than 230 pps to AF41 (UDP)"
    meta nfproto ipv6 meta l4proto udp meta length 0-77 ct direction original meta mark 85 counter ip6 dscp set cs0 comment "Prioritize egress unmarked traffic of packet lengths between 0 and 77 bytes that have more than 230 pps to CS0 (UDP)"
    meta nfproto ipv6 udp sport != { 80, 443 } udp dport != { 80, 443 } meta mark != { 75, 85 } meta length 0-1256 ip6 dscp cs1 counter ip6 dscp set $DSCP_GAMING comment "Prioritize unmarked traffic of packet lengths between 0 and 1256 bytes that have less than 230 pps to $DSCP_GAMING_COMMENT (UDP) - Gaming & VoIP"

    ## Custom port rules (IPv6) ##

    # Game ports - Used by games
    meta nfproto ipv6 tcp sport { $TCP_SRC_GAME_PORTS } counter ip6 dscp set $DSCP_GAMING comment "Game ports to $DSCP_GAMING_COMMENT (TCP)"
    meta nfproto ipv6 tcp dport { $TCP_DST_GAME_PORTS } counter ip6 dscp set $DSCP_GAMING comment "Game ports to $DSCP_GAMING_COMMENT (TCP)"
    meta nfproto ipv6 udp sport { $UDP_SRC_GAME_PORTS } counter ip6 dscp set $DSCP_GAMING comment "Game ports to $DSCP_GAMING_COMMENT (UDP)"
    meta nfproto ipv6 udp dport { $UDP_DST_GAME_PORTS } counter ip6 dscp set $DSCP_GAMING comment "Game ports to $DSCP_GAMING_COMMENT (UDP)"

    # Bulk ports - Used for 'bulk traffic' such as "BitTorrent"
    meta nfproto ipv6 tcp sport { $TCP_SRC_BULK_PORTS } counter ip6 dscp set cs1 comment "Bulk ports to CS1 (TCP)"
    meta nfproto ipv6 tcp dport { $TCP_DST_BULK_PORTS } counter ip6 dscp set cs1 comment "Bulk ports to CS1 (TCP)"
    meta nfproto ipv6 udp sport { $UDP_SRC_BULK_PORTS } counter ip6 dscp set cs1 comment "Bulk ports to CS1 (UDP)"
    meta nfproto ipv6 udp dport { $UDP_DST_BULK_PORTS } counter ip6 dscp set cs1 comment "Bulk ports to CS1 (UDP)"

    # Other ports [OPTIONAL] - Mark wherever you want
    meta nfproto ipv6 tcp sport { $TCP_SRC_OTHER_PORTS } counter ip6 dscp set $DSCP_OTHER_PORTS comment "Other ports to $DSCP_OTHER_PORTS_COMMENT (TCP)"
    meta nfproto ipv6 tcp dport { $TCP_DST_OTHER_PORTS } counter ip6 dscp set $DSCP_OTHER_PORTS comment "Other ports to $DSCP_OTHER_PORTS_COMMENT (TCP)"
    meta nfproto ipv6 udp sport { $UDP_SRC_OTHER_PORTS } counter ip6 dscp set $DSCP_OTHER_PORTS comment "Other ports to $DSCP_OTHER_PORTS_COMMENT (UDP)"
    meta nfproto ipv6 udp dport { $UDP_DST_OTHER_PORTS } counter ip6 dscp set $DSCP_OTHER_PORTS comment "Other ports to $DSCP_OTHER_PORTS_COMMENT (UDP)"
}

chain dscp_marking_ip_addresses_ipv4 {
    ## IP address rules (IPv4) ##

    # Game consoles (Static IP) - Will cover all ports (except ports 80, 443, 8080, Live Streaming and BitTorrent)
    ip daddr { $IPV4_GAME_CONSOLES_STATIC_IP } meta l4proto { tcp, udp } th sport != { 80, 443, 8080, 1935-1936, 2396, 2935 } th dport != { 80, 443, 8080, 1935-1936, 2396, 2935 } meta mark != 75 counter ip dscp set $DSCP_GAMING comment "Game consoles to $DSCP_GAMING_COMMENT (TCP and UDP)"
    ip saddr { $IPV4_GAME_CONSOLES_STATIC_IP } meta l4proto { tcp, udp } th sport != { 80, 443, 8080, 1935-1936, 2396, 2935 } th dport != { 80, 443, 8080, 1935-1936, 2396, 2935 } meta mark != 75 counter ip dscp set $DSCP_GAMING comment "Game consoles to $DSCP_GAMING_COMMENT (TCP and UDP)"

    # TorrentBox (Static IP) - Mark 'all traffic' as bulk
    ip daddr { $IPV4_TORRENTBOX_STATIC_IP } counter ip dscp set cs1 comment "TorrentBox to CS1"
    ip saddr { $IPV4_TORRENTBOX_STATIC_IP } counter ip dscp set cs1 comment "TorrentBox to CS1"

    # Other static IP addresses [OPTIONAL] - Mark 'all traffic' wherever you want
    ip daddr { $IPV4_OTHER_STATIC_IP } counter ip dscp set $DSCP_OTHER_STATIC_IP comment "Other static IP addresses to $DSCP_OTHER_STATIC_IP_COMMENT"
    ip saddr { $IPV4_OTHER_STATIC_IP } counter ip dscp set $DSCP_OTHER_STATIC_IP comment "Other static IP addresses to $DSCP_OTHER_STATIC_IP_COMMENT"
}

    chain dscp_marking_ip_addresses_ipv6 {
    ## IP address rules (IPv6) ##

    # Game consoles (Static IP) - Will cover all ports (except ports 80, 443, 8080, Live Streaming and BitTorrent)
    ip6 daddr { $IPV6_GAME_CONSOLES_STATIC_IP } meta l4proto { tcp, udp } th sport != { 80, 443, 8080, 1935-1936, 2396, 2935 } th dport != { 80, 443, 8080, 1935-1936, 2396, 2935 } meta mark != 75 counter ip6 dscp set $DSCP_GAMING comment "Game consoles to $DSCP_GAMING_COMMENT (TCP and UDP)"
    ip6 saddr { $IPV6_GAME_CONSOLES_STATIC_IP } meta l4proto { tcp, udp } th sport != { 80, 443, 8080, 1935-1936, 2396, 2935 } th dport != { 80, 443, 8080, 1935-1936, 2396, 2935 } meta mark != 75 counter ip6 dscp set $DSCP_GAMING comment "Game consoles to $DSCP_GAMING_COMMENT (TCP and UDP)"

    # TorrentBox (Static IP) - Mark 'all traffic' as bulk
    ip6 daddr { $IPV6_TORRENTBOX_STATIC_IP } counter ip6 dscp set cs1 comment "TorrentBox to CS1"
    ip6 saddr { $IPV6_TORRENTBOX_STATIC_IP } counter ip6 dscp set cs1 comment "TorrentBox to CS1"

    # Other static IP addresses [OPTIONAL] - Mark 'all traffic' wherever you want
    ip6 daddr { $IPV6_OTHER_STATIC_IP } counter ip6 dscp set $DSCP_OTHER_STATIC_IP comment "Other static IP addresses to $DSCP_OTHER_STATIC_IP_COMMENT"
    ip6 saddr { $IPV6_OTHER_STATIC_IP } counter ip6 dscp set $DSCP_OTHER_STATIC_IP comment "Other static IP addresses to $DSCP_OTHER_STATIC_IP_COMMENT"
}
RULES

    ############################################################

    ## Default chain for the rules
    if [ "$CHAIN" = "FORWARD" ]; then
        # FORWARD
        grep "jump" /tmp/00-rules.nft | sed '1q;d' | grep "    " > /dev/null 2>&1 || sed -i "10,13 s/#/ /" /tmp/00-rules.nft > /dev/null 2>&1
        grep "jump" /tmp/00-rules.nft | sed '5q;d' | grep "#   " > /dev/null 2>&1 || sed -i "16 s/c/#c/; 17,22 s/ /#/; 23 s/}/#}/" /tmp/00-rules.nft > /dev/null 2>&1
    elif [ "$CHAIN" != "FORWARD" ]; then
        # POSTROUTING
        grep "jump" /tmp/00-rules.nft | sed '1q;d' | grep "#   " > /dev/null 2>&1 || sed -i "10,13 s/ /#/" /tmp/00-rules.nft > /dev/null 2>&1
        grep "jump" /tmp/00-rules.nft | sed '5q;d' | grep "    " > /dev/null 2>&1 || sed -i "16 s/#c/c/; 17,22 s/#/ /; 23 s/#}/}/" /tmp/00-rules.nft > /dev/null 2>&1
    fi

    ############################################################

    ### Known rules ###

    ## BROADCAST VIDEO rules
    if [ "$BROADCAST_VIDEO" = "yes" ]; then
        # Enable
        grep "Live Streaming ports to" /tmp/00-rules.nft | grep "    " > /dev/null 2>&1 || sed -i '/Live Streaming ports to/s/#   /    /g' /tmp/00-rules.nft > /dev/null 2>&1
    elif [ "$BROADCAST_VIDEO" != "yes" ]; then
        # Disable
        grep "Live Streaming ports to" /tmp/00-rules.nft | grep "#   " > /dev/null 2>&1 || sed -i '/Live Streaming ports to/s/    /#   /g' /tmp/00-rules.nft > /dev/null 2>&1
    fi

    ## GAMING rules
    if [ "$GAMING" = "yes" ]; then
        # Enable
        grep "Known game ports" /tmp/00-rules.nft | grep "    " > /dev/null 2>&1 || sed -i '/Known game ports/s/#   /    /g' /tmp/00-rules.nft > /dev/null 2>&1
    elif [ "$GAMING" != "yes" ]; then
        # Disable
        grep "Known game ports" /tmp/00-rules.nft | grep "#   " > /dev/null 2>&1 || sed -i '/Known game ports/s/    /#   /g' /tmp/00-rules.nft > /dev/null 2>&1
    fi

    ## MULTIMEDIA CONFERENCING rules
    if [ "$MULTIMEDIA_CONFERENCING" = "yes" ]; then
        # Enable
        grep "Known video conferencing ports to" /tmp/00-rules.nft | grep "    " > /dev/null 2>&1 || sed -i '/Known video conferencing ports to/s/#   /    /g' /tmp/00-rules.nft > /dev/null 2>&1
    elif [ "$MULTIMEDIA_CONFERENCING" != "yes" ]; then
        # Disable
        grep "Known video conferencing ports to" /tmp/00-rules.nft | grep "#   " > /dev/null 2>&1 || sed -i '/Known video conferencing ports to/s/    /#   /g' /tmp/00-rules.nft > /dev/null 2>&1
    fi

    ## TELEPHONY rules
    if [ "$TELEPHONY" = "yes" ]; then
        # Enable
        grep "Known VoIP and VoWiFi ports to" /tmp/00-rules.nft | grep "    " > /dev/null 2>&1 || sed -i '/Known VoIP and VoWiFi ports to/s/#   /    /g' /tmp/00-rules.nft > /dev/null 2>&1
    elif [ "$TELEPHONY" != "yes" ]; then
        # Disable
        grep "Known VoIP and VoWiFi ports to" /tmp/00-rules.nft | grep "#   " > /dev/null 2>&1 || sed -i '/Known VoIP and VoWiFi ports to/s/    /#   /g' /tmp/00-rules.nft > /dev/null 2>&1
    fi

    ############################################################

    ### Custom port rules ###

    ## Game ports - Used by games
    if [ "$TCP_SRC_GAME_PORTS" != "" ]; then
        # Enable
        grep "Game ports to" /tmp/00-rules.nft | sed '1q;d' | grep "    " > /dev/null 2>&1 || sed -i '/Game ports to/{G;s/\nX\{0\}//;tend;x;s/^/X/;x};P;d;:end;s/#   /    /;:a;n;ba' /tmp/00-rules.nft > /dev/null 2>&1
        grep "Game ports to" /tmp/00-rules.nft | sed '5q;d' | grep "    " > /dev/null 2>&1 || sed -i '/Game ports to/{G;s/\nX\{4\}//;tend;x;s/^/X/;x};P;d;:end;s/#   /    /;:a;n;ba' /tmp/00-rules.nft > /dev/null 2>&1
    elif [ "$TCP_SRC_GAME_PORTS" = "" ]; then
        # Disable
        grep "Game ports to" /tmp/00-rules.nft | sed '1q;d' | grep "#   " > /dev/null 2>&1 || sed -i '/Game ports to/{G;s/\nX\{0\}//;tend;x;s/^/X/;x};P;d;:end;s/    /#   /;:a;n;ba' /tmp/00-rules.nft > /dev/null 2>&1
        grep "Game ports to" /tmp/00-rules.nft | sed '5q;d' | grep "#   " > /dev/null 2>&1 || sed -i '/Game ports to/{G;s/\nX\{4\}//;tend;x;s/^/X/;x};P;d;:end;s/    /#   /;:a;n;ba' /tmp/00-rules.nft > /dev/null 2>&1
    fi
    if [ "$TCP_DST_GAME_PORTS" != "" ]; then
        # Enable
        grep "Game ports to" /tmp/00-rules.nft | sed '2q;d' | grep "    " > /dev/null 2>&1 || sed -i '/Game ports to/{G;s/\nX\{1\}//;tend;x;s/^/X/;x};P;d;:end;s/#   /    /;:a;n;ba' /tmp/00-rules.nft > /dev/null 2>&1
        grep "Game ports to" /tmp/00-rules.nft | sed '6q;d' | grep "    " > /dev/null 2>&1 || sed -i '/Game ports to/{G;s/\nX\{5\}//;tend;x;s/^/X/;x};P;d;:end;s/#   /    /;:a;n;ba' /tmp/00-rules.nft > /dev/null 2>&1
    elif [ "$TCP_DST_GAME_PORTS" = "" ]; then
        # Disable
        grep "Game ports to" /tmp/00-rules.nft | sed '2q;d' | grep "#   " > /dev/null 2>&1 || sed -i '/Game ports to/{G;s/\nX\{1\}//;tend;x;s/^/X/;x};P;d;:end;s/    /#   /;:a;n;ba' /tmp/00-rules.nft > /dev/null 2>&1
        grep "Game ports to" /tmp/00-rules.nft | sed '6q;d' | grep "#   " > /dev/null 2>&1 || sed -i '/Game ports to/{G;s/\nX\{5\}//;tend;x;s/^/X/;x};P;d;:end;s/    /#   /;:a;n;ba' /tmp/00-rules.nft > /dev/null 2>&1
    fi
    if [ "$UDP_SRC_GAME_PORTS" != "" ]; then
        # Enable
        grep "Game ports to" /tmp/00-rules.nft | sed '3q;d' | grep "    " > /dev/null 2>&1 || sed -i '/Game ports to/{G;s/\nX\{2\}//;tend;x;s/^/X/;x};P;d;:end;s/#   /    /;:a;n;ba' /tmp/00-rules.nft > /dev/null 2>&1
        grep "Game ports to" /tmp/00-rules.nft | sed '7q;d' | grep "    " > /dev/null 2>&1 || sed -i '/Game ports to/{G;s/\nX\{6\}//;tend;x;s/^/X/;x};P;d;:end;s/#   /    /;:a;n;ba' /tmp/00-rules.nft > /dev/null 2>&1
    elif [ "$UDP_SRC_GAME_PORTS" = "" ]; then
        # Disable
        grep "Game ports to" /tmp/00-rules.nft | sed '3q;d' | grep "#   " > /dev/null 2>&1 || sed -i '/Game ports to/{G;s/\nX\{2\}//;tend;x;s/^/X/;x};P;d;:end;s/    /#   /;:a;n;ba' /tmp/00-rules.nft > /dev/null 2>&1
        grep "Game ports to" /tmp/00-rules.nft | sed '7q;d' | grep "#   " > /dev/null 2>&1 || sed -i '/Game ports to/{G;s/\nX\{6\}//;tend;x;s/^/X/;x};P;d;:end;s/    /#   /;:a;n;ba' /tmp/00-rules.nft > /dev/null 2>&1
    fi
    if [ "$UDP_DST_GAME_PORTS" != "" ]; then
        # Enable
        grep "Game ports to" /tmp/00-rules.nft | sed '4q;d' | grep "    " > /dev/null 2>&1 || sed -i '/Game ports to/{G;s/\nX\{3\}//;tend;x;s/^/X/;x};P;d;:end;s/#   /    /;:a;n;ba' /tmp/00-rules.nft > /dev/null 2>&1
        grep "Game ports to" /tmp/00-rules.nft | sed '8q;d' | grep "    " > /dev/null 2>&1 || sed -i '/Game ports to/{G;s/\nX\{7\}//;tend;x;s/^/X/;x};P;d;:end;s/#   /    /;:a;n;ba' /tmp/00-rules.nft > /dev/null 2>&1
    elif [ "$UDP_DST_GAME_PORTS" = "" ]; then
        # Disable
        grep "Game ports to" /tmp/00-rules.nft | sed '4q;d' | grep "#   " > /dev/null 2>&1 || sed -i '/Game ports to/{G;s/\nX\{3\}//;tend;x;s/^/X/;x};P;d;:end;s/    /#   /;:a;n;ba' /tmp/00-rules.nft > /dev/null 2>&1
        grep "Game ports to" /tmp/00-rules.nft | sed '8q;d' | grep "#   " > /dev/null 2>&1 || sed -i '/Game ports to/{G;s/\nX\{7\}//;tend;x;s/^/X/;x};P;d;:end;s/    /#   /;:a;n;ba' /tmp/00-rules.nft > /dev/null 2>&1
    fi

    ## Bulk ports - Used for 'bulk traffic' such as "BitTorrent"
    if [ "$TCP_SRC_BULK_PORTS" != "" ]; then
        # Enable
        grep "Bulk ports to" /tmp/00-rules.nft | sed '1q;d' | grep "    " > /dev/null 2>&1 || sed -i '/Bulk ports to/{G;s/\nX\{0\}//;tend;x;s/^/X/;x};P;d;:end;s/#   /    /;:a;n;ba' /tmp/00-rules.nft > /dev/null 2>&1
        grep "Bulk ports to" /tmp/00-rules.nft | sed '5q;d' | grep "    " > /dev/null 2>&1 || sed -i '/Bulk ports to/{G;s/\nX\{4\}//;tend;x;s/^/X/;x};P;d;:end;s/#   /    /;:a;n;ba' /tmp/00-rules.nft > /dev/null 2>&1
    elif [ "$TCP_SRC_BULK_PORTS" = "" ]; then
        # Disable
        grep "Bulk ports to" /tmp/00-rules.nft | sed '1q;d' | grep "#   " > /dev/null 2>&1 || sed -i '/Bulk ports to/{G;s/\nX\{0\}//;tend;x;s/^/X/;x};P;d;:end;s/    /#   /;:a;n;ba' /tmp/00-rules.nft > /dev/null 2>&1
        grep "Bulk ports to" /tmp/00-rules.nft | sed '5q;d' | grep "#   " > /dev/null 2>&1 || sed -i '/Bulk ports to/{G;s/\nX\{4\}//;tend;x;s/^/X/;x};P;d;:end;s/    /#   /;:a;n;ba' /tmp/00-rules.nft > /dev/null 2>&1
    fi
    if [ "$TCP_DST_BULK_PORTS" != "" ]; then
        # Enable
        grep "Bulk ports to" /tmp/00-rules.nft | sed '2q;d' | grep "    " > /dev/null 2>&1 || sed -i '/Bulk ports to/{G;s/\nX\{1\}//;tend;x;s/^/X/;x};P;d;:end;s/#   /    /;:a;n;ba' /tmp/00-rules.nft > /dev/null 2>&1
        grep "Bulk ports to" /tmp/00-rules.nft | sed '6q;d' | grep "    " > /dev/null 2>&1 || sed -i '/Bulk ports to/{G;s/\nX\{5\}//;tend;x;s/^/X/;x};P;d;:end;s/#   /    /;:a;n;ba' /tmp/00-rules.nft > /dev/null 2>&1
    elif [ "$TCP_DST_BULK_PORTS" = "" ]; then
        # Disable
        grep "Bulk ports to" /tmp/00-rules.nft | sed '2q;d' | grep "#   " > /dev/null 2>&1 || sed -i '/Bulk ports to/{G;s/\nX\{1\}//;tend;x;s/^/X/;x};P;d;:end;s/    /#   /;:a;n;ba' /tmp/00-rules.nft > /dev/null 2>&1
        grep "Bulk ports to" /tmp/00-rules.nft | sed '6q;d' | grep "#   " > /dev/null 2>&1 || sed -i '/Bulk ports to/{G;s/\nX\{5\}//;tend;x;s/^/X/;x};P;d;:end;s/    /#   /;:a;n;ba' /tmp/00-rules.nft > /dev/null 2>&1
    fi
    if [ "$UDP_SRC_BULK_PORTS" != "" ]; then
        # Enable
        grep "Bulk ports to" /tmp/00-rules.nft | sed '3q;d' | grep "    " > /dev/null 2>&1 || sed -i '/Bulk ports to/{G;s/\nX\{2\}//;tend;x;s/^/X/;x};P;d;:end;s/#   /    /;:a;n;ba' /tmp/00-rules.nft > /dev/null 2>&1
        grep "Bulk ports to" /tmp/00-rules.nft | sed '7q;d' | grep "    " > /dev/null 2>&1 || sed -i '/Bulk ports to/{G;s/\nX\{6\}//;tend;x;s/^/X/;x};P;d;:end;s/#   /    /;:a;n;ba' /tmp/00-rules.nft > /dev/null 2>&1
    elif [ "$UDP_SRC_BULK_PORTS" = "" ]; then
        # Disable
        grep "Bulk ports to" /tmp/00-rules.nft | sed '3q;d' | grep "#   " > /dev/null 2>&1 || sed -i '/Bulk ports to/{G;s/\nX\{2\}//;tend;x;s/^/X/;x};P;d;:end;s/    /#   /;:a;n;ba' /tmp/00-rules.nft > /dev/null 2>&1
        grep "Bulk ports to" /tmp/00-rules.nft | sed '7q;d' | grep "#   " > /dev/null 2>&1 || sed -i '/Bulk ports to/{G;s/\nX\{6\}//;tend;x;s/^/X/;x};P;d;:end;s/    /#   /;:a;n;ba' /tmp/00-rules.nft > /dev/null 2>&1
    fi
    if [ "$UDP_DST_BULK_PORTS" != "" ]; then
        # Enable
        grep "Bulk ports to" /tmp/00-rules.nft | sed '4q;d' | grep "    " > /dev/null 2>&1 || sed -i '/Bulk ports to/{G;s/\nX\{3\}//;tend;x;s/^/X/;x};P;d;:end;s/#   /    /;:a;n;ba' /tmp/00-rules.nft > /dev/null 2>&1
        grep "Bulk ports to" /tmp/00-rules.nft | sed '8q;d' | grep "    " > /dev/null 2>&1 || sed -i '/Bulk ports to/{G;s/\nX\{7\}//;tend;x;s/^/X/;x};P;d;:end;s/#   /    /;:a;n;ba' /tmp/00-rules.nft > /dev/null 2>&1
    elif [ "$UDP_DST_BULK_PORTS" = "" ]; then
        # Disable
        grep "Bulk ports to" /tmp/00-rules.nft | sed '4q;d' | grep "#   " > /dev/null 2>&1 || sed -i '/Bulk ports to/{G;s/\nX\{3\}//;tend;x;s/^/X/;x};P;d;:end;s/    /#   /;:a;n;ba' /tmp/00-rules.nft > /dev/null 2>&1
        grep "Bulk ports to" /tmp/00-rules.nft | sed '8q;d' | grep "#   " > /dev/null 2>&1 || sed -i '/Bulk ports to/{G;s/\nX\{7\}//;tend;x;s/^/X/;x};P;d;:end;s/    /#   /;:a;n;ba' /tmp/00-rules.nft > /dev/null 2>&1
    fi

    ## Other ports [OPTIONAL] - Mark wherever you want
    if [ "$TCP_SRC_OTHER_PORTS" != "" ]; then
        # Enable
        grep "Other ports to" /tmp/00-rules.nft | sed '1q;d' | grep "    " > /dev/null 2>&1 || sed -i '/Other ports to/{G;s/\nX\{0\}//;tend;x;s/^/X/;x};P;d;:end;s/#   /    /;:a;n;ba' /tmp/00-rules.nft > /dev/null 2>&1
        grep "Other ports to" /tmp/00-rules.nft | sed '5q;d' | grep "    " > /dev/null 2>&1 || sed -i '/Other ports to/{G;s/\nX\{4\}//;tend;x;s/^/X/;x};P;d;:end;s/#   /    /;:a;n;ba' /tmp/00-rules.nft > /dev/null 2>&1
    elif [ "$TCP_SRC_OTHER_PORTS" = "" ]; then
        # Disable
        grep "Other ports to" /tmp/00-rules.nft | sed '1q;d' | grep "#   " > /dev/null 2>&1 || sed -i '/Other ports to/{G;s/\nX\{0\}//;tend;x;s/^/X/;x};P;d;:end;s/    /#   /;:a;n;ba' /tmp/00-rules.nft > /dev/null 2>&1
        grep "Other ports to" /tmp/00-rules.nft | sed '5q;d' | grep "#   " > /dev/null 2>&1 || sed -i '/Other ports to/{G;s/\nX\{4\}//;tend;x;s/^/X/;x};P;d;:end;s/    /#   /;:a;n;ba' /tmp/00-rules.nft > /dev/null 2>&1
    fi
    if [ "$TCP_DST_OTHER_PORTS" != "" ]; then
        # Enable
        grep "Other ports to" /tmp/00-rules.nft | sed '2q;d' | grep "    " > /dev/null 2>&1 || sed -i '/Other ports to/{G;s/\nX\{1\}//;tend;x;s/^/X/;x};P;d;:end;s/#   /    /;:a;n;ba' /tmp/00-rules.nft > /dev/null 2>&1
        grep "Other ports to" /tmp/00-rules.nft | sed '6q;d' | grep "    " > /dev/null 2>&1 || sed -i '/Other ports to/{G;s/\nX\{5\}//;tend;x;s/^/X/;x};P;d;:end;s/#   /    /;:a;n;ba' /tmp/00-rules.nft > /dev/null 2>&1
    elif [ "$TCP_DST_OTHER_PORTS" = "" ]; then
        # Disable
        grep "Other ports to" /tmp/00-rules.nft | sed '2q;d' | grep "#   " > /dev/null 2>&1 || sed -i '/Other ports to/{G;s/\nX\{1\}//;tend;x;s/^/X/;x};P;d;:end;s/    /#   /;:a;n;ba' /tmp/00-rules.nft > /dev/null 2>&1
        grep "Other ports to" /tmp/00-rules.nft | sed '6q;d' | grep "#   " > /dev/null 2>&1 || sed -i '/Other ports to/{G;s/\nX\{5\}//;tend;x;s/^/X/;x};P;d;:end;s/    /#   /;:a;n;ba' /tmp/00-rules.nft > /dev/null 2>&1
    fi
    if [ "$UDP_SRC_OTHER_PORTS" != "" ]; then
        # Enable
        grep "Other ports to" /tmp/00-rules.nft | sed '3q;d' | grep "    " > /dev/null 2>&1 || sed -i '/Other ports to/{G;s/\nX\{2\}//;tend;x;s/^/X/;x};P;d;:end;s/#   /    /;:a;n;ba' /tmp/00-rules.nft > /dev/null 2>&1
        grep "Other ports to" /tmp/00-rules.nft | sed '7q;d' | grep "    " > /dev/null 2>&1 || sed -i '/Other ports to/{G;s/\nX\{6\}//;tend;x;s/^/X/;x};P;d;:end;s/#   /    /;:a;n;ba' /tmp/00-rules.nft > /dev/null 2>&1
    elif [ "$UDP_SRC_OTHER_PORTS" = "" ]; then
        # Disable
        grep "Other ports to" /tmp/00-rules.nft | sed '3q;d' | grep "#   " > /dev/null 2>&1 || sed -i '/Other ports to/{G;s/\nX\{2\}//;tend;x;s/^/X/;x};P;d;:end;s/    /#   /;:a;n;ba' /tmp/00-rules.nft > /dev/null 2>&1
        grep "Other ports to" /tmp/00-rules.nft | sed '7q;d' | grep "#   " > /dev/null 2>&1 || sed -i '/Other ports to/{G;s/\nX\{6\}//;tend;x;s/^/X/;x};P;d;:end;s/    /#   /;:a;n;ba' /tmp/00-rules.nft > /dev/null 2>&1
    fi
    if [ "$UDP_DST_OTHER_PORTS" != "" ]; then
        # Enable
        grep "Other ports to" /tmp/00-rules.nft | sed '4q;d' | grep "    " > /dev/null 2>&1 || sed -i '/Other ports to/{G;s/\nX\{3\}//;tend;x;s/^/X/;x};P;d;:end;s/#   /    /;:a;n;ba' /tmp/00-rules.nft > /dev/null 2>&1
        grep "Other ports to" /tmp/00-rules.nft | sed '8q;d' | grep "    " > /dev/null 2>&1 || sed -i '/Other ports to/{G;s/\nX\{7\}//;tend;x;s/^/X/;x};P;d;:end;s/#   /    /;:a;n;ba' /tmp/00-rules.nft > /dev/null 2>&1
    elif [ "$UDP_DST_OTHER_PORTS" = "" ]; then
        # Disable
        grep "Other ports to" /tmp/00-rules.nft | sed '4q;d' | grep "#   " > /dev/null 2>&1 || sed -i '/Other ports to/{G;s/\nX\{3\}//;tend;x;s/^/X/;x};P;d;:end;s/    /#   /;:a;n;ba' /tmp/00-rules.nft > /dev/null 2>&1
        grep "Other ports to" /tmp/00-rules.nft | sed '8q;d' | grep "#   " > /dev/null 2>&1 || sed -i '/Other ports to/{G;s/\nX\{7\}//;tend;x;s/^/X/;x};P;d;:end;s/    /#   /;:a;n;ba' /tmp/00-rules.nft > /dev/null 2>&1
    fi

    ############################################################

    ### IP address rules ###

    ## Game consoles (Static IP) - Will cover all ports (except ports 80, 443, 8080, Live Streaming and BitTorrent)
    if [ "$IPV4_GAME_CONSOLES_STATIC_IP" != "" ]; then
        # Enable
        grep "Game consoles to" /tmp/00-rules.nft | sed '1q;d' | grep "    " > /dev/null 2>&1 || sed -i '/Game consoles to/{G;s/\nX\{0\}//;tend;x;s/^/X/;x};P;d;:end;s/#   /    /;:a;n;ba' /tmp/00-rules.nft > /dev/null 2>&1
        grep "Game consoles to" /tmp/00-rules.nft | sed '2q;d' | grep "    " > /dev/null 2>&1 || sed -i '/Game consoles to/{G;s/\nX\{1\}//;tend;x;s/^/X/;x};P;d;:end;s/#   /    /;:a;n;ba' /tmp/00-rules.nft > /dev/null 2>&1
    elif [ "$IPV4_GAME_CONSOLES_STATIC_IP" = "" ]; then
        # Disable
        grep "Game consoles to" /tmp/00-rules.nft | sed '1q;d' | grep "#   " > /dev/null 2>&1 || sed -i '/Game consoles to/{G;s/\nX\{0\}//;tend;x;s/^/X/;x};P;d;:end;s/    /#   /;:a;n;ba' /tmp/00-rules.nft > /dev/null 2>&1
        grep "Game consoles to" /tmp/00-rules.nft | sed '2q;d' | grep "#   " > /dev/null 2>&1 || sed -i '/Game consoles to/{G;s/\nX\{1\}//;tend;x;s/^/X/;x};P;d;:end;s/    /#   /;:a;n;ba' /tmp/00-rules.nft > /dev/null 2>&1
    fi
    if [ "$IPV6_GAME_CONSOLES_STATIC_IP" != "" ]; then
        # Enable
        grep "Game consoles to" /tmp/00-rules.nft | sed '3q;d' | grep "    " > /dev/null 2>&1 || sed -i '/Game consoles to/{G;s/\nX\{2\}//;tend;x;s/^/X/;x};P;d;:end;s/#   /    /;:a;n;ba' /tmp/00-rules.nft > /dev/null 2>&1
        grep "Game consoles to" /tmp/00-rules.nft | sed '4q;d' | grep "    " > /dev/null 2>&1 || sed -i '/Game consoles to/{G;s/\nX\{3\}//;tend;x;s/^/X/;x};P;d;:end;s/#   /    /;:a;n;ba' /tmp/00-rules.nft > /dev/null 2>&1
    elif [ "$IPV6_GAME_CONSOLES_STATIC_IP" = "" ]; then
        # Disable
        grep "Game consoles to" /tmp/00-rules.nft | sed '3q;d' | grep "#   " > /dev/null 2>&1 || sed -i '/Game consoles to/{G;s/\nX\{2\}//;tend;x;s/^/X/;x};P;d;:end;s/    /#   /;:a;n;ba' /tmp/00-rules.nft > /dev/null 2>&1
        grep "Game consoles to" /tmp/00-rules.nft | sed '4q;d' | grep "#   " > /dev/null 2>&1 || sed -i '/Game consoles to/{G;s/\nX\{3\}//;tend;x;s/^/X/;x};P;d;:end;s/    /#   /;:a;n;ba' /tmp/00-rules.nft > /dev/null 2>&1
    fi

    ## TorrentBox (Static IP) - Mark 'all traffic' as bulk
    if [ "$IPV4_TORRENTBOX_STATIC_IP" != "" ]; then
        # Enable
        grep "TorrentBox to" /tmp/00-rules.nft | sed '1q;d' | grep "    " > /dev/null 2>&1 || sed -i '/TorrentBox to/{G;s/\nX\{0\}//;tend;x;s/^/X/;x};P;d;:end;s/#   /    /;:a;n;ba' /tmp/00-rules.nft > /dev/null 2>&1
        grep "TorrentBox to" /tmp/00-rules.nft | sed '2q;d' | grep "    " > /dev/null 2>&1 || sed -i '/TorrentBox to/{G;s/\nX\{1\}//;tend;x;s/^/X/;x};P;d;:end;s/#   /    /;:a;n;ba' /tmp/00-rules.nft > /dev/null 2>&1
    elif [ "$IPV4_TORRENTBOX_STATIC_IP" = "" ]; then
        # Disable
        grep "TorrentBox to" /tmp/00-rules.nft | sed '1q;d' | grep "#   " > /dev/null 2>&1 || sed -i '/TorrentBox to/{G;s/\nX\{0\}//;tend;x;s/^/X/;x};P;d;:end;s/    /#   /;:a;n;ba' /tmp/00-rules.nft > /dev/null 2>&1
        grep "TorrentBox to" /tmp/00-rules.nft | sed '2q;d' | grep "#   " > /dev/null 2>&1 || sed -i '/TorrentBox to/{G;s/\nX\{1\}//;tend;x;s/^/X/;x};P;d;:end;s/    /#   /;:a;n;ba' /tmp/00-rules.nft > /dev/null 2>&1
    fi
    if [ "$IPV6_TORRENTBOX_STATIC_IP" != "" ]; then
        # Enable
        grep "TorrentBox to" /tmp/00-rules.nft | sed '3q;d' | grep "    " > /dev/null 2>&1 || sed -i '/TorrentBox to/{G;s/\nX\{2\}//;tend;x;s/^/X/;x};P;d;:end;s/#   /    /;:a;n;ba' /tmp/00-rules.nft > /dev/null 2>&1
        grep "TorrentBox to" /tmp/00-rules.nft | sed '4q;d' | grep "    " > /dev/null 2>&1 || sed -i '/TorrentBox to/{G;s/\nX\{3\}//;tend;x;s/^/X/;x};P;d;:end;s/#   /    /;:a;n;ba' /tmp/00-rules.nft > /dev/null 2>&1
    elif [ "$IPV6_TORRENTBOX_STATIC_IP" = "" ]; then
        # Disable
        grep "TorrentBox to" /tmp/00-rules.nft | sed '3q;d' | grep "#   " > /dev/null 2>&1 || sed -i '/TorrentBox to/{G;s/\nX\{2\}//;tend;x;s/^/X/;x};P;d;:end;s/    /#   /;:a;n;ba' /tmp/00-rules.nft > /dev/null 2>&1
        grep "TorrentBox to" /tmp/00-rules.nft | sed '4q;d' | grep "#   " > /dev/null 2>&1 || sed -i '/TorrentBox to/{G;s/\nX\{3\}//;tend;x;s/^/X/;x};P;d;:end;s/    /#   /;:a;n;ba' /tmp/00-rules.nft > /dev/null 2>&1
    fi

    ## Other static IP addresses [OPTIONAL] - Mark 'all traffic' wherever you want
    if [ "$IPV4_OTHER_STATIC_IP" != "" ]; then
        # Enable
        grep "Other static IP addresses to" /tmp/00-rules.nft | sed '1q;d' | grep "    " > /dev/null 2>&1 || sed -i '/Other static IP addresses to/{G;s/\nX\{0\}//;tend;x;s/^/X/;x};P;d;:end;s/#   /    /;:a;n;ba' /tmp/00-rules.nft > /dev/null 2>&1
        grep "Other static IP addresses to" /tmp/00-rules.nft | sed '2q;d' | grep "    " > /dev/null 2>&1 || sed -i '/Other static IP addresses to/{G;s/\nX\{1\}//;tend;x;s/^/X/;x};P;d;:end;s/#   /    /;:a;n;ba' /tmp/00-rules.nft > /dev/null 2>&1
    elif [ "$IPV4_OTHER_STATIC_IP" = "" ]; then
        # Disable
        grep "Other static IP addresses to" /tmp/00-rules.nft | sed '1q;d' | grep "#   " > /dev/null 2>&1 || sed -i '/Other static IP addresses to/{G;s/\nX\{0\}//;tend;x;s/^/X/;x};P;d;:end;s/    /#   /;:a;n;ba' /tmp/00-rules.nft > /dev/null 2>&1
        grep "Other static IP addresses to" /tmp/00-rules.nft | sed '2q;d' | grep "#   " > /dev/null 2>&1 || sed -i '/Other static IP addresses to/{G;s/\nX\{1\}//;tend;x;s/^/X/;x};P;d;:end;s/    /#   /;:a;n;ba' /tmp/00-rules.nft > /dev/null 2>&1
    fi
    if [ "$IPV6_OTHER_STATIC_IP" != "" ]; then
        # Enable
        grep "Other static IP addresses to" /tmp/00-rules.nft | sed '3q;d' | grep "    " > /dev/null 2>&1 || sed -i '/Other static IP addresses to/{G;s/\nX\{2\}//;tend;x;s/^/X/;x};P;d;:end;s/#   /    /;:a;n;ba' /tmp/00-rules.nft > /dev/null 2>&1
        grep "Other static IP addresses to" /tmp/00-rules.nft | sed '4q;d' | grep "    " > /dev/null 2>&1 || sed -i '/Other static IP addresses to/{G;s/\nX\{3\}//;tend;x;s/^/X/;x};P;d;:end;s/#   /    /;:a;n;ba' /tmp/00-rules.nft > /dev/null 2>&1
    elif [ "$IPV6_OTHER_STATIC_IP" = "" ]; then
        # Disable
        grep "Other static IP addresses to" /tmp/00-rules.nft | sed '3q;d' | grep "#   " > /dev/null 2>&1 || sed -i '/Other static IP addresses to/{G;s/\nX\{2\}//;tend;x;s/^/X/;x};P;d;:end;s/    /#   /;:a;n;ba' /tmp/00-rules.nft > /dev/null 2>&1
        grep "Other static IP addresses to" /tmp/00-rules.nft | sed '4q;d' | grep "#   " > /dev/null 2>&1 || sed -i '/Other static IP addresses to/{G;s/\nX\{3\}//;tend;x;s/^/X/;x};P;d;:end;s/    /#   /;:a;n;ba' /tmp/00-rules.nft > /dev/null 2>&1
    fi

    ############################################################

    ### nft file ###

    ## Copy the already edited *.nft file to the directory "/etc/nftables.d"
    cp "/tmp/00-rules.nft" "/etc/nftables.d/00-rules.nft"

fi

############################################################

## Reload the firewall to update the rules and check that there are no problems with the rules
fw4 reload

###########################################################
