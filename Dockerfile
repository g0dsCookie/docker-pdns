FROM alpine:3.11

RUN set -eu \
 && apk add --no-cache --virtual .pdns-deps \
	openssl boost lua5.1 curl mariadb-connector-c \
	postgresql-client openldap krb5 sqlite \
	yaml-cpp geoip libsodium protobuf \
 && addgroup pdns \
 && adduser -h /var/empty -s /sbin/nologin -S -g "" -G pdns pdns

ARG MAJOR
ARG MINOR
ARG PATCH

RUN set -eu \
 # install build deps
 && apk add --no-cache --virtual .pdns-bdeps \
	gcc g++ libc-dev rpcgen make tar bzip2 \
	linux-headers openssl-dev boost-dev lua5.1-dev \
	curl-dev mariadb-connector-c-dev postgresql-dev \
	openldap-dev krb5-dev sqlite-dev yaml-cpp-dev \
	geoip-dev libsodium-dev protobuf-dev \
 && BDIR="$(mktemp -d)" && cd "${BDIR}" \
 && PDNS_VERSION="${MAJOR}.${MINOR}.${PATCH}" \
 && PDNS_MODULES="pipe bind ldap lua2 gmysql gpgsql remote gsqlite3 geoip" \
 && MAKEOPTS="-j$(($(nproc)-1))" \
 # download pdns sources
 && curl -sSL -o "pdns-${PDNS_VERSION}.tar.bz2" "https://downloads.powerdns.com/releases/pdns-${PDNS_VERSION}.tar.bz2" \
 && tar -xjf "pdns-${PDNS_VERSION}.tar.bz2" \
 && cd "pdns-${PDNS_VERSION}" \
 # configure pdns
 && ./configure --prefix=/usr --libdir=/usr/lib/powerdns \
	--sysconfdir=/etc/powerdns --disable-static \
	--with-modules= --with-dynmodules="${PDNS_MODULES}" \
	--with-mysql-lib=/usr/lib --enable-tools \
	--with-lua=lua --enable-lua-records \
	--disable-systemd --with-libsodium --with-protobuf \
 # compile and install
 && make ${MAKEOPTS} \
 && make install \
 # cleanup
 && cd && rm -r "${BDIR}" \
 && apk del .pdns-bdeps

EXPOSE 53/udp
EXPOSE 53/tcp

VOLUME /etc/powerdns

ENTRYPOINT ["/usr/sbin/pdns_server", "--config-dir=/etc/powerdns", "--daemon=no"]
