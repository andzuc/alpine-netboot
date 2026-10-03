#!/bin/sh
set -e

LOG_SOCKET=/tmp/${VM_TITLE}/serial0
echo 'Creazione socket ${LOG_SOCKET} e ascolto avviato...'
mkdir -p /tmp/${VM_TITLE}
exec socat -d -u UNIX-LISTEN:${LOG_SOCKET},mode=777,unlink-early=1,reuseaddr,fork STDOUT
