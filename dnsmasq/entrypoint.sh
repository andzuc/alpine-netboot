#!/bin/sh
set -e

ALPINE_VERSION=${ALPINE_VERSION:-3.20.3}
if [ -z "${SERVER_IP+x}" ]; then
    echo "SERVER_IP is undefined"
    exit 1
fi
if [ -z "${HTTPD_IP+x}" ]; then
    echo "HTTPD_IP is undefined"
    exit 1
fi
if [ -z "${ROUTER_IP+x}" ]; then
    echo "ROUTER_IP is undefined"
    exit 1
fi
ARCH=${ARCH:-x86_64}
INTERFACE=$(ip addr show | awk -v ip="${SERVER_IP}" '$0 ~ "inet " ip "/" {print $NF}' | cut -d: -f1)
if [ -z "${PXE_MAC+x}" ]; then
    echo "PXE_MAC is undefined"
    exit 1
fi
if [ -z "${PXE_IP+x}" ]; then
    echo "PXE_IP is undefined"
    exit 1
fi

echo "=== PXE Server Alpine ==="
echo "Alpine Version : ${ALPINE_VERSION}"
echo "Server IP      : ${SERVER_IP}"
echo "Httpd IP       : ${HTTPD_IP}"
echo "Router IP      : ${ROUTER_IP}"
echo "Architecture   : ${ARCH}"
echo "Interface      : ${INTERFACE}"
echo "PXE MAC        : ${PXE_MAC}"
echo "PXE IP         : ${PXE_IP}"

# chainload iPXE: https://ipxe.org/howto/chainloading
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
    chmod -R a+r /pxe
    echo ">>> Download complete"
fi

# iPXE config
cat > /pxe/boot.ipxe << EOF
#!ipxe

echo === Alpine Netboot ===
dhcp || goto failed

set base http://${HTTPD_IP}/boot

kernel \${base}/vmlinuz-lts \\
    console=tty0 modules=loop,squashfs quiet nomodeset \\
    alpine_repo=https://dl-cdn.alpinelinux.org/alpine/v${ALPINE_VERSION%.*}/main \\
    modloop=\${base}/modloop-lts || goto failed

initrd \${base}/initramfs-lts || goto failed
boot || goto failed

:failed
echo Boot failed
shell
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
dhcp-host=${PXE_MAC},${PXE_IP},set:pxe
dhcp-range=${PXE_IP},${PXE_IP},12h

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
