#!/bin/sh
set -e

echo 'Creazione socket e ascolto avviato...'
mkdir -p /tmp/${VM_TITLE}
exec socat -d -u UNIX-LISTEN:/tmp/${VM_TITLE}/serial0,mode=777,unlink-early=1,reuseaddr,fork STDOUT
