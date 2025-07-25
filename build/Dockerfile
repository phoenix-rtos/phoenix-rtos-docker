FROM ubuntu:24.04 AS build

# notes:
#  - each RUN/COPY creates new docker layer, try to keep them to the minimum
#  - multistage build doesn't give us any advantage (we need gcc/libc-dev in the final image also)

LABEL org.opencontainers.image.ref.name=build
LABEL org.opencontainers.image.source=https://github.com/phoenix-rtos/phoenix-rtos-docker

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
        git \
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

# use --build-arg FORCE_REBUILD=$(date +%s) to force rebuild from this line
ARG FORCE_REBUILD=unknown
# use to check-out specific commit of phoenix-rtos-project (--build-arg PHOENIX_PROJECT_REF=release/3.0)
ARG PHOENIX_PROJECT_REF=HEAD

# download toolchain build script and ececute it for all platforms
# remove build artifacts from the final image
# make toolchain writeable to everyone, to allow USER mapping
RUN set -ex; \
    mkdir -p /usr/src/phoenix && \
    cd /usr/src/phoenix && \
    git clone --recursive https://github.com/phoenix-rtos/phoenix-rtos-project.git && \
    (cd phoenix-rtos-project && git checkout ${PHOENIX_PROJECT_REF}) && \
    (cd phoenix-rtos-project && git submodule update --recursive --force) && \
    mkdir -p /opt/phoenix && (cd phoenix-rtos-project && git rev-parse --short HEAD > /opt/phoenix/git-version) && \
    cd phoenix-rtos-project/phoenix-rtos-build/toolchain/ && \
    ./build-toolchain.sh arm-phoenix /opt/phoenix/ && \
    ./build-toolchain.sh aarch64-phoenix /opt/phoenix/ && \
    ./build-toolchain.sh i386-pc-phoenix /opt/phoenix/ && \
    ./build-toolchain.sh riscv64-phoenix /opt/phoenix/ && \
    ./build-toolchain.sh sparc-phoenix /opt/phoenix/ && \
    rm -rf /opt/phoenix/_build && \
    rm -rf /usr/src/phoenix && \
    chmod -R a+rwX /opt/phoenix


# phoenix-rtos build dependencies
#   cpio: kernel
#   hidapi: phoenixd
#   mtd-utils: jffs2 image (imx6ull)
#   genext2fs: ext2 image (ia32)
#   xxd: stm32 image
#   vim: 'ex' needed for lighttpd build.sh
#   cmake: needed for zlib build.sh
#   python3, python3-yaml, python3-jinja2: phoenix-rtos-build tools
# git: safe.directory: as we're usually running image as root, ensure `git` won't complain about file ownership
# copy to global config to share for all users / all HOMEs

RUN apt-get update && \
# make sure debconf doesn't try to prompt (e.g. tzdata on Ubuntu)
    DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
        cpio \
        genext2fs \
        libhidapi-dev \
        mtd-utils \
        vim \
        xxd \
        cmake \
        python3 \
        python3-yaml \
        python3-jinja2 \
    && rm -rf /var/lib/apt/lists/* \
    && git config --global --add safe.directory '*' \
    && cp /root/.gitconfig /etc/gitconfig


# Add bear tool to be able to generate compilation database during build step
RUN set -ex; \
    git clone --branch 2.4.4 https://github.com/rizsotto/Bear.git && \
    cd Bear && \
    cmake -DCMAKE_INSTALL_PREFIX=/opt/bear . && \
    make all install && \
    cd .. && rm -rf Bear


ENV PATH="/opt/phoenix/arm-phoenix/bin:/opt/phoenix/aarch64-phoenix/bin:/opt/phoenix/i386-pc-phoenix/bin:/opt/phoenix/riscv64-phoenix/bin:/opt/phoenix/sparc-phoenix/bin:${PATH}"
ENV PATH="/opt/bear/bin:${PATH}"

COPY --chmod=0755 entrypoint.sh /usr/bin/

ENTRYPOINT ["/usr/bin/entrypoint.sh"]
