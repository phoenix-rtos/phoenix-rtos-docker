FROM phoenixrtos/build:latest

ARG DEVEL_XILINX_PLO_VERSION=2021.2
ARG TARGETPLATFORM

# download python3, qemu and libs to compile Xilinx qemu
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
    && rm -rf /var/lib/apt/lists/*

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

ENV PATH="/opt/phoenix/utils:${PATH}"

ENTRYPOINT ["/bin/bash", "-l", "-c"]
