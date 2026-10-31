#!/bin/sh
set -e

IF_VNET=$(ip addr show | awk -v ip="${ROUTER_IP}" '$0 ~ "inet " ip "/" {print $NF}' | cut -d: -f1)
IF_EXT=$(ip -o -4 route show default | awk '{print $5; exit}')

echo "vnet interface: $IF_VNET"
echo "external interface: $IF_EXT"

iptables -t nat -F POSTROUTING
iptables -t nat -A POSTROUTING -s 192.168.101.0/24 ! -o "$IF_VNET" -j MASQUERADE
iptables -A FORWARD -i "$IF_VNET" -j ACCEPT
iptables -A FORWARD -o "$IF_VNET" -m state --state RELATED,ESTABLISHED -j ACCEPT

echo "Router ready"
exec tail -f /dev/null
