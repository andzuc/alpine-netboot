ARG ALPINE_BASE_VERSION
FROM alpine:${ALPINE_BASE_VERSION}

RUN apk add --no-cache dnsmasq wget

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 67/udp 69/udp

ENTRYPOINT ["/entrypoint.sh"]
