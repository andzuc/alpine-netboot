# Dockerfile.http
ARG ALPINE_BASE_VERSION
FROM alpine:${ALPINE_BASE_VERSION}

RUN apk add --no-cache socat

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
