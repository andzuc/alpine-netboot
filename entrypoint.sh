#!/bin/sh
set -e

ALPINE_VERSION=${ALPINE_VERSION:-3.20.3}
SERVER_IP=${SERVER_IP:-192.168.1.100}
ARCH=${ARCH:-x86_64}
INTERFACE=${INTERFACE:-eth0}
PXE_MAC=${PXE_MAC:-aa:bb:cc:dd:ee:ff}

echo "=== PXE Server Alpine ==="
echo "Alpine Version : ${ALPINE_VERSION}"
echo "Server IP      : ${SERVER_IP}"
echo "Architecture   : ${ARCH}"
echo "Interface      : ${INTERFACE}"
echo "PXE MAC        : ${PXE_MAC}"

# Scarica Alpine netboot solo se non presente
if [ ! -f /pxe/boot/vmlinuz-lts ]; then
    echo ">>> Scarico Alpine netboot..."
    mkdir -p /pxe/boot
    NETBOOT_URL="https://dl-cdn.alpinelinux.org/alpine/v${ALPINE_VERSION%.*}/releases/${ARCH}/alpine-netboot-${ALPINE_VERSION}-${ARCH}.tar.gz"
    echo ">>> URL: ${NETBOOT_URL}"
    wget -q --show-progress -O /tmp/netboot.tar.gz "${NETBOOT_URL}"
    tar -xzf /tmp/netboot.tar.gz -C /pxe
    rm /tmp/netboot.tar.gz
    echo ">>> Download completato"
else
    echo ">>> File Alpine già presenti. Skip download."
fi

# Genera la configurazione dnsmasq al volo
cat > /etc/dnsmasq.conf << EOF
# Ascolta solo su questo IP
listen-address=${SERVER_IP}
bind-interfaces

# TFTP
enable-tftp
tftp-root=/pxe

# DHCP solo per il MAC specificato
dhcp-host=${PXE_MAC},192.168.101.160,set:pxe
dhcp-range=192.168.101.160,192.168.101.160,12h

dhcp-option=tag:pxe,option:router,192.168.101.1
dhcp-option=tag:pxe,option:dns-server,1.1.1.1,8.8.8.8

# Boot file
dhcp-boot=tag:pxe,boot/vmlinuz-lts,,${SERVER_IP}

log-dhcp
log-facility=-
EOF

echo ">>> Avvio dnsmasq su ${INTERFACE} (DHCP solo per ${PXE_MAC})..."
exec dnsmasq --no-daemon -C /etc/dnsmasq.conf
