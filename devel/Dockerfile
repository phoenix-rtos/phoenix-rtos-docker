ARG BASE_IMAGE_VERSION=latest
FROM phoenixrtos/build:${BASE_IMAGE_VERSION}

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
        ninja-build \
        tini \
        net-tools \
    && rm -rf /var/lib/apt/lists/* \
    && c_rehash # needed for armv7 CA certs to work

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
ARG DEVEL_XILINX_VERSION=2024.2
RUN if [ "$TARGETPLATFORM" != "linux/arm/v7" ]; then \
        git clone https://github.com/Xilinx/qemu.git && \
        cd qemu && \
        git checkout tags/xilinx_v${DEVEL_XILINX_VERSION} && \
        mkdir build && cd build && \
        ../configure --target-list="aarch64-softmmu" --enable-fdt --disable-kvm --disable-xen --enable-gcrypt --bindir="/usr/bin" --prefix="/usr" && \
        make && \
        strip --strip-unneeded aarch64-softmmu/qemu-system-aarch64 && \
        cp aarch64-softmmu/qemu-system-aarch64 /usr/bin && \
        cd ../.. && rm -rf qemu; \
    fi

ARG QEMU_SYSTEM_VERSION=v10.0.0

# on 24.04 apt doesn't provide qemu-system-arm that support running armv8r52-mps3an536 target
# install qemu-system-arm > v9.0.2 to run armv8r52-mps3an536 target
# this version of qemu also did some enhancements for sparc architecture
# so also install qemu-system-sparc > v9.0.2 to run SPARC LEON3 target
RUN git clone https://github.com/qemu/qemu.git --branch ${QEMU_SYSTEM_VERSION} && \
    cd qemu && \
    mkdir build && cd build && \
    ../configure --target-list=arm-softmmu,sparc-softmmu --disable-kvm --disable-xen --enable-gcrypt --bindir="/usr/bin" --prefix="/usr" && \
    make -j 9 && \
    strip --strip-unneeded qemu-system-arm qemu-system-sparc && \
    cp qemu-system-arm qemu-system-sparc /usr/bin && \
    cd ../.. && rm -rf qemu;

ARG JLINK_VERSION=V810b

# install Jlink tools for 32-bit armv7 architecture and 64-bit amd architecture
RUN if [ "$TARGETPLATFORM" = "linux/arm/v7" ]; then \
        JLINK_FILENAME="JLink_Linux_${JLINK_VERSION}_arm.tgz"; \
    elif [ "$TARGETPLATFORM" = "linux/amd64" ]; then \
        JLINK_FILENAME="JLink_Linux_${JLINK_VERSION}_x86_64.tgz"; \
    elif [ "$TARGETPLATFORM" = "linux/arm64" ]; then \
        JLINK_FILENAME="JLink_Linux_${JLINK_VERSION}_arm64.tgz"; \
    else \
        echo "Unknown target platform: $TARGETPLATFORM" && exit 1; \
    fi; \
    mkdir -p /opt/SEGGER && \
    (cd /opt/SEGGER && \
    wget --post-data "accept_license_agreement=accepted" "https://www.segger.com/downloads/jlink/${JLINK_FILENAME}" && \
    tar xf "${JLINK_FILENAME}" && \
    rm "${JLINK_FILENAME}" && \
    chmod a-w JLink_Linux_V* && \
    echo "$(ls -d JLink_Linux_V*)" > version && \
    mv JLink_Linux_V* JLink && \
    mkdir -p /etc/udev/rules.d && \
    cp JLink/99-jlink.rules /etc/udev/rules.d/99-jlink.rules)


### install our tools as a last step - as they will change the most oftem

# prepare virtual env
RUN python3 -m venv /opt/venv

ENV PATH="/opt/venv/bin:$PATH"

# use to check-out specific commit of phoenix-rtos-project (--build-arg PHOENIX_PROJECT_REF=release/3.0)
ARG PHOENIX_PROJECT_REF=HEAD

# install hostutils and test runner requirements
RUN git clone --recursive https://github.com/phoenix-rtos/phoenix-rtos-project.git && \
    cd phoenix-rtos-project && \
    git checkout ${PHOENIX_PROJECT_REF} && \
    git submodule update --recursive --force && \
    pip3 install -r phoenix-rtos-tests/requirements.txt --no-cache-dir && \
    NOSAN=1 TARGET=host-generic-pc ./phoenix-rtos-build/build.sh host && \
    mkdir -p /opt/phoenix/utils && \
    git rev-parse --short HEAD > /opt/phoenix/utils/git-version && \
    (cd _build/host-generic-pc/prog.stripped && cp -a * /opt/phoenix/utils) && \
    cd .. && rm -rf phoenix-rtos-project && \
    chmod -R a+rX /opt/phoenix/utils


ENV PATH="/opt/phoenix/utils:/opt/SEGGER/JLink:${PATH}"

ENTRYPOINT ["/bin/bash", "-l", "-c"]
