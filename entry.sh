#!/bin/sh -e

export PATH="$PATH:/usr/share/easy-rsa"

cd /etc/openvpn

echo '> initialising easy-rsa pki'
easyrsa init-pki

echo '> generating CA'
easyrsa --batch build-ca nopass

echo '> generating server pki'
# can't find a way to do this non-interactive (use build-server-full instead)
# easyrsa --batch gen-req "$(hostname -s)" nopass
# easyrsa show-req "$(hostname -s)"
# interactive only
# easyrsa sign-req server "$(hostname -s)"
easyrsa build-server-full "$(hostname -s)" nopass

echo '> generating DH params'
easyrsa gen-dh

echo 'list contents of /etc/openvpn/pki'
ls -lahR /etc/openvpn/pki

echo '> linking pki'
ln -sv /etc/openvpn/pki/ca.crt /etc/openvpn/ca.crt
ln -sv "/etc/openvpn/pki/issued/$(hostname -s).crt" /etc/openvpn/server.crt
ln -sv "/etc/openvpn/pki/private/$(hostname -s).key" /etc/openvpn/server.key
ln -sv /etc/openvpn/pki/dh.pem /etc/openvpn/dh2048.pem

echo '> last minute openvpn reconfigures'
# comment out the extra shared key, we are not that advanced (yet)
sed -i '/tls-auth ta.key 0/c\;tls-auth ta.key 0' "$OPENVPN_CONFIG_FILE"

# uncomment to print out the dir listing
# echo '> contents of /etc/openvpn'
# ls -l /etc/openvpn

echo "> openvpn config: $OPENVPN_CONFIG_FILE"
# print out the full config file if you need debugging purposes
# cat "$OPENVPN_CONFIG_FILE"

echo "> $@" && exec "$@"
