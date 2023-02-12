FROM debian:buster-slim

RUN set -ex \
    # Official Mopidy install for Debian/Ubuntu along with some extensions
    # (see https://docs.mopidy.com/en/latest/installation/debian/ )
 && apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y \
        curl \
        dumb-init \
        gcc \
        git \
        gnupg \
        gstreamer1.0-alsa \
        gstreamer1.0-plugins-bad \
        python3-crypto \
        python3-distutils \
 && mkdir -p /usr/local/share/keyrings \
 && curl -L -o /usr/local/share/keyrings/mopidy-archive-keyring.gpg \
        https://apt.mopidy.com/mopidy.gpg \
 && curl -L https://apt.mopidy.com/mopidy.list -o /etc/apt/sources.list.d/mopidy.list \
 && apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y \
        mopidy \
 && curl -L https://bootstrap.pypa.io/get-pip.py | python3 - \
 && pip install -U six pyasn1 requests[security] cryptography \
 && git clone https://github.com/jellyfin/mopidy-jellyfin.git \
 && cd mopidy-jellyfin && pip install . \
 && pip install \
        Mopidy-Iris \
        Mopidy-Mpd \
        pyopenssl \
 && mkdir -p /var/lib/mopidy/.config \
 && ln -s /config /var/lib/mopidy/.config/mopidy \
    # Clean-up
 && apt-get purge --auto-remove -y \
        curl \
        gcc \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* ~/.cache

# Start helper script.
COPY entrypoint.sh /entrypoint.sh

# Default configuration.
COPY mopidy.conf /config/mopidy.conf

# Copy the pulse-client configuratrion.
COPY pulse-client.conf /etc/pulse/client.conf

VOLUME ["/var/lib/mopidy/local", "/var/lib/mopidy/media", "/config"]

EXPOSE 6600 6680 5555/udp

ENTRYPOINT ["/usr/bin/dumb-init", "/entrypoint.sh"]

CMD ["/usr/bin/mopidy"]
