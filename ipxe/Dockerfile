# Dockerfile.http
ARG ALPINE_BASE_VERSION
FROM alpine:${ALPINE_BASE_VERSION}

COPY bin /ipxe/bin

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
