FROM phoenixrtos/build:latest

ARG DEVEL_XILINX_PLO_VERSION=2021.2
ARG TARGETPLATFORM

LABEL org.opencontainers.image.ref.name=devel
LABEL org.opencontainers.image.source=https://github.com/phoenix-rtos/phoenix-rtos-docker

# download python3, qemu and libs to compile Xilinx qemu
# libusb-1.0 and tclsh needed for appropriate build and using openocd
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        python3-dev \
        python3-venv \
        python3-pip \
        opensbi \
        qemu-system-i386 \
        qemu-system-misc \
        qemu-utils \
        libgcrypt20-dev \
        zlib1g-dev \
        libpixman-1-dev \
        u-boot-qemu \
        gdb-multiarch \
        libusb-1.0 \
        tclsh \
    && rm -rf /var/lib/apt/lists/* \
    && c_rehash # needed for armv7 CA certs to work

# prepare virtual env
RUN python3 -m venv /opt/venv

ENV PATH="/opt/venv/bin:$PATH"

# get python requirements
RUN pip3 install --no-cache-dir \
    pyserial \
    pyyaml \
    pexpect \
    RPi.GPIO

# install hostutils
RUN git clone --recursive https://github.com/phoenix-rtos/phoenix-rtos-project.git && \
    cd phoenix-rtos-project && \
    TARGET=host-generic-pc make -C phoenix-rtos-hostutils -f Makefile.old all && \
    mkdir -p /opt/phoenix/utils && \
    (cd _build/host-generic-pc/prog.stripped && cp phoenixd psu psdisk /opt/phoenix/utils) && \
    cd .. && rm -rf phoenix-rtos-project && \
    chmod -R a+rwX /opt/phoenix/utils

# install openocd in 0.12 version
RUN mkdir -p /etc/udev/rules.d && \
    git clone https://github.com/openocd-org/openocd.git --branch v0.12.0 && \
    cd openocd && \
    ./bootstrap && \
    ./configure --enable-stlink && make install && \
    cp contrib/60-openocd.rules /etc/udev/rules.d/ && \
    cd ../ && rm -rf openocd

# install qemu from xilinx
# qemu xilinx doesn't support 32-bit architecture, skip armv7 architectures
RUN if [ "$TARGETPLATFORM" != "linux/arm/v7" ]; then \
        git clone https://github.com/Xilinx/qemu.git && \
        cd qemu && \
        git checkout tags/xilinx_v${DEVEL_XILINX_PLO_VERSION} && \
        git submodule update --init dtc && \
        mkdir build && cd build && \
        ../configure --target-list="aarch64-softmmu" --enable-fdt --disable-kvm --disable-xen --enable-gcrypt --bindir="/usr/bin" --prefix="/usr" && \
        make && \
        strip --strip-unneeded aarch64-softmmu/qemu-system-aarch64 && \
        cp aarch64-softmmu/qemu-system-aarch64 /usr/bin && \
        cd ../.. && rm -rf qemu; \
    fi

# install Jlink tools for 32-bit armv7 architecture and 64-bit amd architecture
RUN if [ "$TARGETPLATFORM" = "linux/arm/v7" ]; then \
        JLINK_FILENAME="JLink_Linux_arm"; \
    elif [ "$TARGETPLATFORM" = "linux/amd64" ]; then \
        JLINK_FILENAME="JLink_Linux_x86_64"; \
    fi; \
    mkdir -p /opt/SEGGER && \
    (cd /opt/SEGGER && \
    wget --post-data "accept_license_agreement=accepted" "https://www.segger.com/downloads/jlink/${JLINK_FILENAME}.tgz" && \
    tar xf "${JLINK_FILENAME}.tgz" && \
    rm "${JLINK_FILENAME}.tgz" && \
    chmod a-w JLink_Linux_V* && \
    echo "$(ls -d JLink_Linux_V*)" > version && \
    mv JLink_Linux_V* JLink && \
    mkdir -p /etc/udev/rules.d && \
    cp JLink/99-jlink.rules /etc/udev/rules.d/99-jlink.rules)

ENV PATH="/opt/phoenix/utils:/opt/SEGGER/JLink:${PATH}"

ENTRYPOINT ["/bin/bash", "-l", "-c"]
