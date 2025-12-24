ARG BASE_VERSION=15
FROM ghcr.io/daemonless/base:${BASE_VERSION}

ARG FREEBSD_ARCH=amd64
LABEL org.opencontainers.image.title="transmission-wireguard" \
      org.opencontainers.image.description="Transmission BitTorrent client with WireGuard VPN on FreeBSD" \
      org.opencontainers.image.source="https://github.com/daemonless/transmission-wireguard" \
      org.opencontainers.image.url="https://transmissionbt.com/" \
      org.opencontainers.image.documentation="https://github.com/transmission/transmission" \
      org.opencontainers.image.licenses="GPL-2.0-or-later" \
      org.opencontainers.image.vendor="daemonless" \
      org.opencontainers.image.authors="daemonless" \
      io.daemonless.port="9091" \
      io.daemonless.arch="${FREEBSD_ARCH}" \
      io.daemonless.volumes="/downloads,/watch" \
      io.daemonless.pkg-source="containerfile" \
      org.freebsd.jail.vnet="new"

# Install transmission, wireguard tools, and pf for kill switch
RUN pkg update && \
    pkg install -y \
        transmission-daemon \
        transmission-web \
        wireguard-tools \
        ca_root_nss && \
    mkdir -p /app && pkg info transmission-daemon | sed -n 's/.*Version.*: *//p' > /app/version && \
    pkg clean -ay && \
    rm -rf /var/cache/pkg/* /var/db/pkg/repos/*

# Create directories (transmission user/group created by package)
RUN mkdir -p /config /downloads/complete /downloads/incomplete /watch \
             /etc/wireguard && \
    chown -R bsd:bsd /config /downloads /watch

# Copy service definitions and init scripts
COPY root/ /

# Make scripts executable
RUN chmod +x /etc/services.d/*/run /etc/cont-init.d/* 2>/dev/null || true

# Set up s6 service links

EXPOSE 9091 51413 51413/udp
VOLUME /config /downloads /watch


