FROM alpine:3.6

MAINTAINER Chris Fordham <chris@fordham-nagy.id.au>

ENV DEBUG=false \
    HELPER_LOG_LEVEL=DEBUG \
    OPENVPN_CONFIG_FILE=/etc/openvpn/server.conf \
    PRINT_CLIENT_PROFILE=false \
    PRINT_OPENVPN_CONFIG=false \
    PRINT_CA_CERT=false \
    REMOTE_HOST=127.0.0.1 \
    REMOTE_PORT=1194

ADD https://raw.githubusercontent.com/outlook/openvpn-azure-ad-auth/master/requirements.txt /tmp/requirements.txt

WORKDIR /tmp

RUN apk update && \
    apk add --no-cache --upgrade \
      bash \
      gcc \
      linux-headers \
      musl-dev \
      libffi-dev \
      openssl-dev \
      openvpn \
      easy-rsa \
      python \
      python-dev \
      py-pip \
      google-authenticator && \
    pip install -r requirements.txt && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir -p /usr/local/bin

COPY entry.sh /usr/local/bin/entry.sh

COPY config.yaml /etc/openvpn/config.yaml

ADD https://raw.githubusercontent.com/OpenVPN/openvpn/master/sample/sample-config-files/server.conf \
    https://raw.githubusercontent.com/OpenVPN/openvpn/master/sample/sample-config-files/client.conf \
    https://raw.githubusercontent.com/outlook/openvpn-azure-ad-auth/master/openvpn-azure-ad-auth.py \
    /etc/openvpn/

RUN cp /usr/share/easy-rsa/vars.example /etc/openvpn/vars && \
    cp /usr/share/easy-rsa/openssl-1.0.cnf /etc/openvpn/openssl-1.0.cnf && \
    ln -s /usr/share/easy-rsa/x509-types /etc/openvpn/x509-types && \
    chmod +x /etc/openvpn/openvpn-azure-ad-auth.py && \
    rm -f /tmp/requirements.txt

VOLUME ["/etc/openvpn"]

EXPOSE 1194/udp

WORKDIR /etc/openvpn

ENTRYPOINT ["/usr/local/bin/entry.sh"]

CMD openvpn --config "$OPENVPN_CONFIG_FILE"
