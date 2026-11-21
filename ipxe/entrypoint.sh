#!/bin/sh
set -x

if [ ! -f "${PXE_VOLUME}/undionly.kpxe" ]; then
    echo ">>> Copy undionly.kpxe..."
    cp /ipxe/bin/undionly.kpxe "${PXE_VOLUME}/undionly.kpxe"
    echo ">>> Copy complete"
fi
