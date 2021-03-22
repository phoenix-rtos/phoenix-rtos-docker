# building stage, we can use feature-rich environment from which we will copy the results into final image
FROM ubuntu:20.04 AS build
#FROM buildpack-deps:20.04 AS build

# notes:
#  - each RUN/COPY creates new docker layer, try to keep them to the minimum
#  - multistage build doesn't give us any advantage (we need gcc/libc-dev in the final image also)


# TODO: change
MAINTAINER Phoenix Systems DevOps Team

# additional packets needed for toolchain compilation
RUN apt-get update && \
# make sure debconf doesn't try to prompt (e.g. tzdata on Ubuntu)
    DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
# toolchain build dependencies
        autoconf \
        automake \
        bzip2 \
        ca-certificates \
        g++ \
        gcc \
        libc6-dev \
        libglib2.0-dev \
        libmaxminddb-dev \
        libtool \
        make \
        patch \
        texinfo \
        unzip \
        wget \
        xz-utils \
    && rm -rf /var/lib/apt/lists/*

# download toolchain build script and ececute it for all platforms
# remove build artifacts from the final image
# make toolchain writeable to everyone, to allow USER mapping
RUN set -ex; \
    mkdir -p /usr/src/phoenix && \
    cd /usr/src/phoenix && \
    wget https://github.com/phoenix-rtos/phoenix-rtos-build/archive/master.zip && \
    unzip master.zip && \
    cd phoenix-rtos-build-master/toolchain/ && \
    ./build-toolchain.sh arm-phoenix /opt/phoenix/ && \
    ./build-toolchain.sh i386-pc-phoenix /opt/phoenix/ && \
    ./build-toolchain.sh riscv64-phoenix /opt/phoenix/ && \
    rm -rf /opt/phoenix/*.patch /opt/phoenix/binutils-* /opt/phoenix/gcc-* && \
    rm -rf /usr/src/phoenix && \
    chmod -R a+rwX /opt/phoenix


# phoenix-rtos build dependencies
# bcc, bin86: ia32 plo
# cpio: kernel
# hidapi: phoenixd
# mtd-utils: jffs2 image (imx6ull)
# genext2fs: ext2 image (ia32)
# xxd: stm32 image

RUN apt-get update && \
# make sure debconf doesn't try to prompt (e.g. tzdata on Ubuntu)
    DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
        bcc \
        bin86 \
        cpio \
        genext2fs \
        git \
        libhidapi-dev \
        mtd-utils \
        xxd \
    && rm -rf /var/lib/apt/lists/*


ENV PATH="/opt/phoenix/arm-phoenix/bin:/opt/phoenix/i386-pc-phoenix/bin:/opt/phoenix/riscv64-phoenix/bin:${PATH}"

ENTRYPOINT ["./phoenix-rtos-build/build.sh"]

