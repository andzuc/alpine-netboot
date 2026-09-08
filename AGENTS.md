# AGENTS.md

## Overview
Containerized PXE/netboot server for Alpine Linux using `dnsmasq` (DHCP proxy/TFTP) and `thttpd` (HTTP), with an Ansible EE container and QEMU/libvirt Vagrant VM testing integration (`virt-n270`).

## Environment & Configuration
- Create `.env` from `.env.example` prior to running services.
- Required / Key Environment Variables:
  - `SERVER_IP`: Host IP where PXE/HTTP services run.
  - `ROUTER_IP`: Gateway and DNS server IP injected into DHCP options.
  - `PXE_MAC`: Specific client MAC address (`dnsmasq` restricts DHCP leases strictly to this MAC).
  - `ALPINE_VERSION` (e.g. `3.20.3`) / `ALPINE_BASE_VERSION` (e.g. `3.20`).
  - `ARCH`: Boot architecture (`x86`, `x86_64`).

## Services & Container Execution
- Start containers: `docker compose up --build -d`
- **`pxe-dnsmasq`**:
  - Context: `./dnsmasq` (Dockerfile: `dnsmasq/Dockerfile`).
  - Requires `network_mode: host` and `cap_add: [NET_ADMIN]`.
  - Automatically fetches `undionly.kpxe` and Alpine netboot release archives into the `alpine-netboot` volume (`/pxe`) on first run.
  - `dnsmasq/entrypoint.sh` dynamically generates `/pxe/boot.ipxe` and `/etc/dnsmasq.conf`.
- **`pxe-httpd`**:
  - Context: `./httpd` (Dockerfile: `httpd/Dockerfile`).
  - Mounts volume `/pxe` read-only and serves it over HTTP (port 80) via `thttpd` for iPXE boot asset retrieval (`vmlinuz-lts`, `initramfs-lts`, `modloop-lts`).
- **`pxe-ansible`**:
  - Context: `./ansible` (Dockerfile: `ansible/Dockerfile`).

## Submodule & CI Notes
- `virt-n270` is a Git submodule for Vagrant/libvirt i386 test VM configurations. Initialize submodules with `git submodule update --init --recursive`.
- CI (`.github/workflows/build-image.yml`) relies on host QEMU/libvirt/Vagrant and external `virt-utils` scripts to execute `./bin/provision` and upload built Vagrant boxes.
