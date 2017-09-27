# docker-openvpn

[![License][badge-license]][apache2]
[![GitHub Issues][badge-gh-issues]][gh-issues]
[![GitHub Stars][badge-gh-stars]][gh-stars]
[![GitHub Forks][badge-gh-forks]][gh-forks]
[![Docker Build][badge-docker-build]][docker-builds]
[![Docker Build Status][badge-docker-build-status]][docker-builds]
[![Docker Pulls][badge-docker-pulls]][docker-hub]
[![Twitter][badge-twitter]][tweet]

:whale: A Docker image for OpenVPN.

Azure AD version uses the upstream helper script,  https://github.com/outlook/openvpn-azure-ad-auth.

## Prerequisites

You'll need to set up an App Registration in Azure AD.  It only needs the default "Sign in and read user profile" permission.
Once setup, you can grant permissions in required permissions in the app registration in the portal or run `/etc/openvpn/openvpn-azure-ad-auth.py --consent` inside the container
The grant/consent can be done per user or by an admin to consent for all users.

## Build

    $ docker build -t flaccid/openvpn:azure-ad .

Or, for RPi:

    $ docker build --file Dockerfile.arm32v6 -t flaccid/openvpn:azure-ad .

## Run

NOTE: Not yet minimised privileges - it can vary greatly depending on your Docker setup and OS which is why a privileged container makes sense on the practical level (for now).

    $ docker run -it --privileged flaccid/openvpn

Practical usage with Azure AD included:

    $ docker run -it --privileged \
        -e CLIENT_ID="$CLIENT_ID" \
        -e TENANT_ID="$TENANT_ID" \
        -e PRINT_CLIENT_PROFILE=true \
         -p 1194:1194/udp \
          flaccid/openvpn:azure-ad

Persist your existing CA certificate, plus add debug mode:

    $ docker run -it --privileged \
        -e CLIENT_ID="$CLIENT_ID" \
        -e TENANT_ID="$TENANT_ID" \
        -e CA_CERTIFICATE="$CA_CERTIFICATE" \
        -e DEBUG=true \
        -e PRINT_CLIENT_PROFILE=true \
         -p 1194:1194/udp \
          flaccid/openvpn:azure-ad

Once the server is up, copy the printed client profile, save it and run something like `openvpn --config client.ovpn`.

Full example specifying pre-generated authoritative PKI:

    $ docker run -it --privileged \
        -e CLIENT_ID="$CLIENT_ID" \
        -e TENANT_ID="$TENANT_ID" \
        -e CA_CERTIFICATE="$CA_CERTIFICATE" \
        -e CA_KEY="$CA_KEY" \
        -e DH_PARAMS="$DH_PARAMS" \
        -e REMOTE_HOST="$REMOTE_HOST" \
        -e PRINT_CLIENT_PROFILE=true \
        -e DEBUG=true \
        -p 1194:1194/udp \
          flaccid/openvpn:azure-ad

### Runtime Environment Variables

There should be a reasonable amount of flexibility using the available variables. If not please raise an issue so your use case can be covered!

- `CLIENT_ID` - Azure AD Client ID [required]
- `TENANT_ID` - Azure AD Tenant ID [required]
- `CA_CERTIFICATE` - TLS/SSL CA certificate (x509) [optional]
- `DH_PARAMS` - Diffie hellman parameters (providing them speeds up startup time) [optional]
- `SERVER_CERTIFICATE` - TLS/SSL server certificate (x509) [optional]
- `SERVER_KEY` - TLS/SSL server key (x509) [optional]
- `PUSH_ROUTES` - additional routes to push to clients, e.g. `192.168.0.0 255.255.255.0,10.9.2.0 255.255.255.0` [optional]
- `PRINT_CLIENT_PROFILE` - print the client .ovpn on startup [optional]
- `DEBUG` - print out more stuff on startup [optional]
- `NAT` - set to `true` to enable Network Address Translation on the OpenVPN server to masquerade traffic out of the host [optional]

### PKI Persistence

#### Rancher

TODO: Rancher Secrets

#### RightScale

Consider just `CA_CERTIFICATE`, `SERVER_CERTIFICATE` and `SERVER_KEY` in RightScale credentials for safe keeping.
You might copy/paste these when running up the stack via the Rancher Catalog.

Suggested credential names: `OPENVPN_CA_CERT`, `OPENVPN_SERVER_CERT`, `OPENVPN_SERVER_KEY`.

License and Authors
-------------------
- Author: Chris Fordham (<chris@fordham-nagy.id.au>)

```text
Copyright 2017, Chris Fordham

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```

[badge-license]: https://img.shields.io/badge/license-Apache%202-blue.svg
[badge-gh-issues]: https://img.shields.io/github/issues/flaccid/docker-openvpn.svg
[badge-gh-forks]: https://img.shields.io/github/forks/flaccid/docker-openvpn.svg
[badge-gh-stars]: https://img.shields.io/github/stars/flaccid/docker-openvpn.svg
[badge-docker-build]: https://img.shields.io/docker/automated/flaccid/openvpn.svg
[badge-docker-build-status]: https://img.shields.io/docker/build/flaccid/openvpn.svg
[badge-docker-pulls]: https://img.shields.io/docker/pulls/flaccid/openvpn.svg
[badge-twitter]: https://img.shields.io/twitter/url/https/github.com/flaccid/docker-openvpn.svg?style=social
[gh-issues]: https://github.com/flaccid/docker-openvpn/issues
[gh-stars]: https://github.com/flaccid/docker-openvpn/stargazers
[gh-forks]: https://github.com/flaccid/docker-openvpn/network
[docker-builds]: https://hub.docker.com/r/flaccid/openvpn/builds/
[docker-hub]: https://registry.hub.docker.com/u/flaccid/openvpn/
[apache2]: https://www.apache.org/licenses/LICENSE-2.0
[tweet]: https://twitter.com/intent/tweet?text=check%20out%20https://goo.gl/KS5vis&url=%5Bobject%20Object%5D
