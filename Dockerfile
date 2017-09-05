FROM alpine:3.6

MAINTAINER Chris Fordham <chris@fordham-nagy.id.au>

RUN apk update && \
  apk add --no-cache --upgrade openvpn && \
  rm -rf /var/lib/apt/lists/*
