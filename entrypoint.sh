#!/bin/sh
set -e

# Valori di default (possono essere sovrascritti dalle variabili d'ambiente)
ALPINE_VERSION=${ALPINE_VERSION:-3.20.0}
SERVER_IP=${SERVER_IP:-192.168.1.100}
ARCH=${ARCH:-x86_64}

echo "=== PXE Server Alpine ==="
echo "Alpine Version : ${ALPINE_VERSION}"
echo "Server IP      : ${SERVER_IP}"
echo "Architecture   : ${ARCH}"

# Scarica i file solo se non esistono
if [ ! -f /pxe/boot/vmlinuz-lts ]; then
    echo ">>> File Alpine non trovati. Scarico netboot..."
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
no-dhcp-interface=lo
dhcp-range=192.168.1.0,proxy

enable-tftp
tftp-root=/pxe

# Boot file (UEFI / BIOS)
dhcp-boot=boot/vmlinuz-lts,,${SERVER_IP}

log-dhcp
log-facility=-
EOF

echo ">>> Avvio dnsmasq..."
exec dnsmasq --no-daemon -C /etc/dnsmasq.conf
