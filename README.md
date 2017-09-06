# docker-openvpn
:whale: A Docker image for OpenVPN

Azure AD version uses https://github.com/outlook/openvpn-azure-ad-auth.

#### Run

NOTE: Not yet minimised privileges - it can vary greatly depending on your Docker setup and OS which is why a privileged container makes sense on the practical level (for now).

    $ docker run -it --privileged flaccid/openvpn

Azure AD usage:

    $ docker run -it --privileged -e CLIENT_ID="$CLIENT_ID" -e TENANT_ID="$TENANT_ID" flaccid/openvpn
