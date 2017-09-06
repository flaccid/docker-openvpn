#!/bin/sh -e

export PATH="$PATH:/usr/share/easy-rsa"

# for azure ad, tenant id and client id are required
([ -z "$TENANT_ID" ] || [ -z "$CLIENT_ID" ]) && \
  echo '$TENANT_ID and $CLIENT_ID are required environment variables.' && \
  exit 1

set_conf(){
  directive="$1"
  values="$(echo $@ | cut -d ' ' -f 2,3,4,5)"
  # echo "directive is $directive"
  # echo "values is $values"

  # quick and dirty append for now
  echo "$directive" "$values" >> "$OPENVPN_CONFIG_FILE"
}

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

# echo '> list contents of /etc/openvpn/pki'
# ls -lahR /etc/openvpn/pki

echo '> linking pki'
ln -sv /etc/openvpn/pki/ca.crt /etc/openvpn/ca.crt
ln -sv "/etc/openvpn/pki/issued/$(hostname -s).crt" /etc/openvpn/server.crt
ln -sv "/etc/openvpn/pki/private/$(hostname -s).key" /etc/openvpn/server.key
ln -sv /etc/openvpn/pki/dh.pem /etc/openvpn/dh2048.pem

echo '> re-configure openvpn'
# original file known to not have a trailing return
echo '' >> "$OPENVPN_CONFIG_FILE"
# comment out the extra shared key, we are not that advanced (yet)
sed -i '/tls-auth ta.key 0/c\;tls-auth ta.key 0' "$OPENVPN_CONFIG_FILE"
set_conf auth-user-pass-verify /usr/local/bin/openvpn-azure-ad-auth.py via-env
set_conf script-security 3

# uncomment to print out the dir listing
# echo '> contents of /etc/openvpn'
# ls -l /etc/openvpn

[ "$PRINT_OPENVPN_CONFIG" = 'true' ] && cat "$OPENVPN_CONFIG_FILE"

echo "> reconfigure azure-ad config"
sed -i "s/{{log_level}}/$TENANT_ID/" /etc/azure-ad/config.yaml
sed -i "s/{{log_level}}/$CLIENT_ID/" /etc/azure-ad/config.yaml
sed -i "s/{{log_level}}/$HELPER_LOG_LEVEL/" /etc/azure-ad/config.yaml

echo "> openvpn config: $OPENVPN_CONFIG_FILE"
# print out the full config file if you need debugging purposes
# cat "$OPENVPN_CONFIG_FILE"

echo "> $@" && exec "$@"
