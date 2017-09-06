FROM alpine:3.6

MAINTAINER Chris Fordham <chris@fordham-nagy.id.au>

ENV OPENVPN_CONFIG_FILE=/etc/openvpn/server.conf

ADD https://raw.githubusercontent.com/outlook/openvpn-azure-ad-auth/master/requirements.txt /tmp/requirements.txt

WORKDIR /tmp

RUN apk update && \
    apk add --no-cache --upgrade gcc linux-headers musl-dev libffi-dev openssl-dev openvpn easy-rsa python python-dev py-pip && \
    pip install -r requirements.txt && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir -p /usr/local/bin

COPY entry.sh /usr/local/bin/entry.sh

ADD https://raw.githubusercontent.com/OpenVPN/openvpn/master/sample/sample-config-files/server.conf \
      /etc/openvpn/server.conf

ADD https://raw.githubusercontent.com/OpenVPN/openvpn/master/sample/sample-config-files/client.conf \
      /etc/openvpn/client.conf

ADD https://raw.githubusercontent.com/outlook/openvpn-azure-ad-auth/master/openvpn-azure-ad-auth.py \
      /usr/local/bin/openvpn-azure-ad-auth.py

RUN cp /usr/share/easy-rsa/vars.example /etc/openvpn/vars && \
    cp /usr/share/easy-rsa/openssl-1.0.cnf /etc/openvpn/openssl-1.0.cnf && \
    ln -s /usr/share/easy-rsa/x509-types /etc/openvpn/x509-types && \
    rm -f /tmp/requirements.txt

VOLUME ["/etc/openvpn"]

EXPOSE 1194/udp

WORKDIR /etc/openvpn

ENTRYPOINT ["/usr/local/bin/entry.sh"]

CMD openvpn --config "$OPENVPN_CONFIG_FILE"
