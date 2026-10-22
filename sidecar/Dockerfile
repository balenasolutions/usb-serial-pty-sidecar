FROM alpine:3.24.3

RUN apk add --no-cache socat

COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]