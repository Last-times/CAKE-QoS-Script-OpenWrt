# CAKE QoS Script (OpenWrt)

This is the script that I made months ago (to self-learning) and until today I have time to share it.

## Quick Overview
1. The script launches the CAKE qdisc (like SQM would do), and **you do not need SQM at all**.
2. The script uses the **veth method** on the ingress side to make the **DSCP marking**  work and fix this problem:

> With **dual-dsthost** enabled, a single host with many tcp sessions (like when torrenting) is prevented from hogging all the bandwidth, **but if you are actually using that host**, the torrent will still hog that host's bandwidth and to fix that problem you need **QoS** using **DSCP marking**, so that the torrent traffic and other such hogs goes into the "**bulk class**", then that host will see a **big improvement** in all other traffic types.

3. It has rules to prioritize **non-bulk** *unmarked traffic* like **gaming** and **VoIP**, that means you don't need to add **game ports**, but if you want you can also add **game ports** and static IP of **game consoles** to prioritize that traffic (although it is not necessary).
4. It has rules to give high priority to known **Video conferencing**, **VoIP** and **VoWiFi** ports.
5. Easily change the **default OpenWrt settings** like `default qdisc`, `TCP congestion control` and `ECN`.
6. **`irqbalance`** and **`Packet Steering`** options to equally distribute the load of packet processing over all available cores and probably increase performance.
7. It has **`Init Script`** so that from the LuCI web interface (**`System -> Startup`**) you can Enable, Disable, Start, Restart and Stop the script.
8. It has **`Hotplug`** to automatically reload the script.

## Pre-requisites
To use this script, you need to install these packages:
* tc-tiny
* kmod-sched-cake
* kmod-veth
* kmod-tcp-bbr
* irqbalance
* htop (Optional)

Copy and paste this into your SSH client:
```
opkg update && opkg install tc-tiny kmod-sched-cake kmod-veth kmod-tcp-bbr irqbalance
```

## Install
Copy and paste this into your SSH client:
```
rm /root/cake.sh; rm /etc/init.d/cake; rm /etc/hotplug.d/iface/99-cake; rm /etc/nftables.d/*-rules.nft; wget -O /root/cake.sh "https://raw.githubusercontent.com/Last-times/CAKE-QoS-Script-OpenWrt/main/cake.sh"; chmod 755 /root/cake.sh
```
The **`cake.sh`** script is located in the **`/root/`** folder on the router and you have to edit this:
1. Change the **CAKE settings** according to your connection type and also change the other settings (like rules, ports, IP address,  irqbalance, etc.).
2. You can delete the **ports** and **IP address** from the script, because are just examples.
3. Once you've finished editing the script, use this command to run the script:
```
./cake.sh
```

Or download the script to edit it with the **notepad** and then place the edited script into the **`/root/`** folder on the router, then change the permissions of the script with this command **`chmod 755 /root/cake.sh`** and run the script with the command above **`./cake.sh`**
* **GitHub**: [Download the script](https://github.com/Last-times/CAKE-QoS-Script-OpenWrt/archive/refs/heads/main.zip)

## CLI
Command to run the script:
```
./cake.sh
```

Others important commands:
```
# To check if the DSCP marking is working
tc -s qdisc


# To check your CAKE settings
tc qdisc | grep cake


# To check the veth devices
ip link show


# To check the nftables rules
nft list ruleset


# To check if changed the default OpenWrt settings
sysctl net.core.default_qdisc
sysctl net.ipv4.tcp_congestion_control
sysctl net.ipv4.tcp_ecn


# To check if irqbalance or packet steering are enabled or disabled
uci show irqbalance.irqbalance.enabled
uci show network.globals.packet_steering
```

## Tip
* Don't use **`Software flow offloading`**, it will break the **rules** and **CAKE**.

## Uninstall/Remove
Copy and paste this into your SSH client:
```
/etc/init.d/cake stop; rm /root/cake.sh; rm /etc/init.d/cake; rm /etc/hotplug.d/iface/99-cake; rm /etc/nftables.d/*-rules.nft; sed -i "/default_qdisc/d; /tcp_congestion_control/d; /tcp_ecn/d" /etc/sysctl.conf; uci set dhcp.odhcpd.loglevel="4"; uci set irqbalance.irqbalance.enabled="0"; uci del network.globals.packet_steering; uci commit && reload_config
```

## DSCP Information
* [Differentiated Services Field Codepoints (DSCP)](https://www.iana.org/assignments/dscp-registry/dscp-registry.xhtml#dscp-registry-2)
* [RFC 8325 - Mapping Diffserv to IEEE 802.11](https://datatracker.ietf.org/doc/html/rfc8325#section-4)
* [RFC 8325 - WiFi QoS Mappings](https://mrncciew.com/2021/09/14/rfc-8325-wifi-qos-mappings/)
* [RFC 7561 - Mapping Quality of Service (QoS) Procedures of Proxy Mobile IPv6 (PMIPv6) and WLAN](https://datatracker.ietf.org/doc/html/rfc7561#section-4.2)

![RFC 8325 - Mapping Diffserv to IEEE 802.11](https://raw.githubusercontent.com/Last-times/CAKE-QoS-Script-OpenWrt/main/RFC%208325%20-%20Mapping%20Diffserv%20to%20IEEE%20802.11.png)

![RFC 8325 - WiFi QoS Mappings](https://raw.githubusercontent.com/Last-times/CAKE-QoS-Script-OpenWrt/main/RFC%208325%20-%20WiFi%20QoS%20Mappings.png)

![RFC 7561 - Mapping Quality of Service (QoS) Procedures of Proxy Mobile IPv6 (PMIPv6) and WLAN](https://raw.githubusercontent.com/Last-times/CAKE-QoS-Script-OpenWrt/main/RFC%207561%20-%20Mapping%20Quality%20of%20Service%20(QoS)%20Procedures%20of%20Proxy%20Mobile%20IPv6%20(PMIPv6)%20and%20WLAN.png)
