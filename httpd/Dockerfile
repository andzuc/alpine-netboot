# Dockerfile.http
ARG ALPINE_BASE_VERSION
FROM alpine:${ALPINE_BASE_VERSION}

RUN apk add --no-cache thttpd

EXPOSE 80

CMD ["thttpd", "-D", "-h", "0.0.0.0", "-p", "80", "-d", "/pxe", "-u", "nobody", "-l", "-"]
