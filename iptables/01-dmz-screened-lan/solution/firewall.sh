#!/bin/bash

# flush previous rules
iptables -F INPUT
iptables -F OUTPUT
iptables -F FORWARD
iptables -t nat -F

# policies
iptables -P INPUT DROP
iptables -P OUTPUT DROP
iptables -P FORWARD ACCEPT

# NAT

iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
## publish host3 (http/https) and host4 (dns) to the WAN
iptables -t nat -A PREROUTING -i eth0 -d 192.168.122.254 -p TCP -m multiport --dports 80,443 -j DNAT --to-destination 172.16.2.3
iptables -t nat -A PREROUTING -i eth0 -d 192.168.122.254 -p UDP --dport 53 -j DNAT --to-destination 172.16.2.4

# FORWARD

## replies of allowed connections
iptables -A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A FORWARD -m state --state INVALID -j DROP

## no telnet/snmp between networks
iptables -A FORWARD -p TCP --dport 23 -j DROP
iptables -A FORWARD -p UDP --dport 161 -j DROP

## lan1 is screened: nobody starts connections into it
iptables -A FORWARD -o eth1 -m state --state NEW -j DROP

## dmz inbound: ssh from lan1, http/https on host3, dns on host4
iptables -A FORWARD -i eth1 -o eth2 -p TCP --dport 22 -m state --state NEW -j ACCEPT
iptables -A FORWARD -o eth2 -d 172.16.2.3 -p TCP -m multiport --dports 80,443 -m state --state NEW -j ACCEPT
iptables -A FORWARD -o eth2 -d 172.16.2.4 -p UDP --dport 53 -m state --state NEW -j ACCEPT
iptables -A FORWARD -o eth2 -m state --state NEW -j DROP

## dmz outbound: only http/https/dns to the internet
iptables -A FORWARD -i eth2 -o eth0 -p TCP -m multiport --dports 80,443 -m state --state NEW -j ACCEPT
iptables -A FORWARD -i eth2 -o eth0 -p UDP --dport 53 -m state --state NEW -j ACCEPT
iptables -A FORWARD -i eth2 -o eth0 -m state --state NEW -j DROP

## everything else (lan1 as client) falls through to the ACCEPT policy

# FIREWALL

## replies of allowed connections
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

## ssh/telnet only from host1, checked by mac, ip and interface
iptables -A INPUT -i eth1 -s 10.1.0.1 -m mac --mac-source 02:42:da:ee:2f:00 -p TCP -m multiport --dports 22,23 -m state --state NEW -j ACCEPT

## lan1 and lan2 can ping firewall
iptables -A INPUT -i eth1 -p ICMP --icmp-type echo-request -j ACCEPT
iptables -A INPUT -i eth2 -p ICMP --icmp-type echo-request -j ACCEPT
## firewall can ping out
iptables -A OUTPUT -p ICMP --icmp-type echo-request -j ACCEPT

## firewall as client: http/https/dns only on lan2 and internet
iptables -A OUTPUT -o eth2 -d 172.16.2.3 -p TCP -m multiport --dports 80,443 -m state --state NEW -j ACCEPT
iptables -A OUTPUT -o eth2 -d 172.16.2.4 -p UDP --dport 53 -m state --state NEW -j ACCEPT
iptables -A OUTPUT -o eth0 -p TCP -m multiport --dports 80,443 -m state --state NEW -j ACCEPT
iptables -A OUTPUT -o eth0 -p UDP --dport 53 -m state --state NEW -j ACCEPT
