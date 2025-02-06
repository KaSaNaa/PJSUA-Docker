# Use the latest Debian image
FROM debian:latest

# Install dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    libasound2-dev \
    libv4l-dev \
    libsdl2-dev \
    libavcodec-dev \
    libavformat-dev \
    libswscale-dev \
    libportaudio2 \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Download and build PJSIP
WORKDIR /usr/src
RUN curl -LO https://github.com/pjsip/pjproject/archive/refs/tags/2.13.tar.gz \
    && tar xzf 2.13.tar.gz \
    && cd pjproject-2.13 \
    && ./configure --prefix=/usr --enable-shared --disable-video --disable-sound \
    && make -j$(nproc) \
    && make install \
    && ldconfig

# Ensure pjsua is available
RUN if [ ! -f /usr/bin/pjsua ]; then \
        cp /usr/src/pjproject-2.13/pjsip-apps/bin/pjsua-x86_64-unknown-linux-gnu /usr/bin/pjsua && \
        chmod +x /usr/bin/pjsua; \
    fi

# Set entrypoint
ENTRYPOINT ["/usr/bin/pjsua"]
