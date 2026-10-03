# Dockerfile.http
ARG ALPINE_BASE_VERSION
FROM alpine:${ALPINE_BASE_VERSION}

RUN apk add --no-cache socat \
    python3 py3-pip

RUN pip install ansi2txt --break-system-packages

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
