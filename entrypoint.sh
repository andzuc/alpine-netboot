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
echo "Router IP      : ${ROUTER_IP}"
echo "Architecture   : ${ARCH}"
echo "Interface      : ${INTERFACE}"
echo "PXE MAC        : ${PXE_MAC}"

if [ ! -f /pxe/undionly.kpxe ]; then
    echo ">>> Download undionly.kpxe..."
    wget -P /pxe https://boot.ipxe.org/undionly.kpxe
    echo ">>> Download complete"
fi

# Scarica Alpine netboot solo se non presente
if [ ! -f /pxe/boot/vmlinuz-lts ]; then
    echo ">>> Download Alpine netboot..."
    mkdir -p /pxe/boot
    NETBOOT_URL="https://dl-cdn.alpinelinux.org/alpine/v${ALPINE_VERSION%.*}/releases/${ARCH}/alpine-netboot-${ALPINE_VERSION}-${ARCH}.tar.gz"
    echo ">>> URL: ${NETBOOT_URL}"
    wget -q --show-progress -O /tmp/netboot.tar.gz "${NETBOOT_URL}"
    tar -xzf /tmp/netboot.tar.gz -C /pxe
    rm /tmp/netboot.tar.gz
    echo ">>> Download complete"
fi

# iPXE config
cat > /pxe/boot.ipxe << EOF
#!ipxe

dhcp

kernel tftp://${SERVER_IP}/boot/vmlinuz-lts \
    console=tty0 modules=loop,squashfs quiet nomodeset \
    alpine_repo=https://dl-cdn.alpinelinux.org/alpine/v${ALPINE_VERSION%.*}/main \
    modloop=tftp://${SERVER_IP}/boot/modloop-lts

initrd tftp://${SERVER_IP}/boot/initramfs-lts
boot
EOF

# dnsmasq config
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

# Riconoscimento iPXE
dhcp-match=set:ipxe,175

# Gateway e DNS
dhcp-option=tag:pxe,option:router,${ROUTER_IP}
dhcp-option=tag:pxe,option:dns-server,${ROUTER_IP}

# Boot file
dhcp-boot=tag:pxe,tag:!ipxe,undionly.kpxe,,${SERVER_IP}
dhcp-boot=tag:pxe,tag:ipxe,tftp://${SERVER_IP}/boot.ipxe,,${SERVER_IP}

log-dhcp
log-facility=-
EOF

echo ">>> Start dnsmasq on ${INTERFACE} (DHCP only for ${PXE_MAC})..."
exec dnsmasq --no-daemon -C /etc/dnsmasq.conf
