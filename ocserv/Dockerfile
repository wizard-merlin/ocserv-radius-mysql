FROM ubuntu
ENV OC_VERSION=0.11.9 RAD_VERSION=1.2.8
RUN apt-get update \
    && apt-get install -y libgnutls28-dev libev-dev libwrap0-dev libpam0g-dev liblz4-dev libseccomp-dev libreadline-dev libnl-route-3-dev libkrb5-dev liboath-dev libradcli-dev autoconf libtool automake libgnutls28-dev abi-compliance-checker gnutls-bin vim curl iptables \
    && curl -SL https://github.com/radcli/radcli/releases/download/$RAD_VERSION/radcli-$RAD_VERSION.tar.gz -o radcli.tar.gz \
    && mkdir -p /usr/src/radcli \
    && tar xvzf radcli.tar.gz -C /usr/src/radcli --strip-components=1 \
    && rm radcli.tar.gz \
    && cd /usr/src/radcli \
    && ./configure --sysconfdir=/etc/ \
    && make \
    && make install \
    && cd /root \
    && curl -SL ftp://ftp.infradead.org/pub/ocserv/ocserv-$OC_VERSION.tar.xz -o ocserv.tar.xz \
    && mkdir -p /usr/src/ocserv \
    && tar -xf ocserv.tar.xz -C /usr/src/ocserv --strip-components=1 \
    && rm ocserv.tar.xz* \
    && cd /usr/src/ocserv \
    && ./configure --sysconfdir=/etc/ \
    && make \
    && make install \
    && cd /root

WORKDIR /etc/ocserv
EXPOSE 443
COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

COPY radiusclient.conf /etc/radcli/radiusclient.conf
COPY servers /etc/radcli/servers
COPY dictionary /etc/radcli/dictionary
COPY ocserv.conf /etc/ocserv/ocserv.conf
CMD ["/usr/local/sbin/ocserv", "--config=/etc/ocserv/ocserv.conf", "--foreground", "--debug=2"]
