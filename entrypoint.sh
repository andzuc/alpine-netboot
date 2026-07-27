#!/bin/sh
set -e

ALPINE_VERSION=${ALPINE_VERSION:-3.20.3}
SERVER_IP=${SERVER_IP:-192.168.1.100}
ARCH=${ARCH:-x86_64}
INTERFACE=${INTERFACE:-eth0}

echo "=== PXE Server Alpine ==="
echo "Alpine Version : ${ALPINE_VERSION}"
echo "Server IP      : ${SERVER_IP}"
echo "Architecture   : ${ARCH}"
echo "Interface      : ${INTERFACE}"

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
# Ascolta solo sull'interfaccia fisica
interface=${INTERFACE}
bind-interfaces

# Proxy DHCP
dhcp-range=192.168.101.0,proxy

# TFTP
enable-tftp
tftp-root=/pxe

# === Configurazione PXE corretta ===
# BIOS (Arch 00000)
pxe-service=x86PC, "Boot Alpine", boot/vmlinuz-lts

# UEFI x86_64 (Arch 00007)
pxe-service=x86-64_EFI, "Boot Alpine UEFI", boot/vmlinuz-lts

# Opzionale: forza next-server
dhcp-option=option:tftp-server,${SERVER_IP}
dhcp-option=option:bootfile-name,boot/vmlinuz-lts

log-dhcp
log-queries
log-facility=-
EOF

echo ">>> Avvio dnsmasq solo su ${INTERFACE}..."
exec dnsmasq --no-daemon -C /etc/dnsmasq.conf
