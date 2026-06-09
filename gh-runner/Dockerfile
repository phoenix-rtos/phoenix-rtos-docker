### WARN: multi-stage: BUILD STAGE ###
FROM ubuntu:24.04 AS build

# install host build environment
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
        autoconf \
        automake \
        ca-certificates \
        curl \
        libatomic1 \
        libhidapi-dev \
        libusb-1.0-0-dev \
        gcc \
        git \
        libtool \
        make \
        pkgconf \
        python3-dev \
        python3-pip \
        python3-venv \
        tclsh \
    && rm -rf /var/lib/apt/lists/*


# install openocd in 0.12 version
RUN mkdir -p /etc/udev/rules.d && \
    git clone --depth 1 https://github.com/openocd-org/openocd.git --branch v0.12.0 && \
    cd openocd && \
    ./bootstrap && \
    ./configure --enable-stlink && make install -j 9 && \
    cp contrib/60-openocd.rules /etc/udev/rules.d/ && \
    cd ../ && rm -rf openocd

# prepare virtual env for test runner
RUN python3 -m venv /opt/venv

ENV PATH="/opt/venv/bin:$PATH"

# install all dependencies here in the build stage as some need to be compiled on arm64
RUN pip3 install --no-cache-dir pyocd requests && \
    pyocd pack install mcxn947

# use to check-out specific commit of phoenix-rtos-project (--build-arg PHOENIX_PROJECT_REF=release/3.0)
ARG PHOENIX_PROJECT_REF=HEAD

# install hostutils and test runner requirements
RUN git clone --recursive https://github.com/phoenix-rtos/phoenix-rtos-project.git && \
    cd phoenix-rtos-project && \
    git checkout ${PHOENIX_PROJECT_REF} && \
    pip3 install -r phoenix-rtos-tests/requirements.txt --no-cache-dir && \
    NOSAN=1 TARGET=host-generic-pc ./phoenix-rtos-build/build.sh host && \
    mkdir -p /opt/phoenix/utils && \
    git rev-parse --short HEAD > /opt/phoenix/utils/git-version && \
    (cd _build/host-generic-pc/prog.stripped && cp -a * /opt/phoenix/utils) && \
    cd .. && rm -rf phoenix-rtos-project && \
    chmod -R a+rX /opt/phoenix/utils

# stage every run-stage artifact under a single tree so it can be
# copied into the final image in one layer
RUN mkdir -p /rootfs/etc/udev/rules.d /rootfs/opt /rootfs/usr/local/bin \
             /rootfs/usr/local/share /rootfs/root/.local/share && \
    cp /etc/udev/rules.d/60-openocd.rules /rootfs/etc/udev/rules.d/ && \
    mv /opt/phoenix /rootfs/opt/phoenix && \
    mv /usr/local/bin/openocd /rootfs/usr/local/bin/ && \
    mv /usr/local/share/openocd /rootfs/usr/local/share/openocd && \
    mv /opt/venv /rootfs/opt/venv && \
    mv /root/.local/share/cmsis-pack-manager /rootfs/root/.local/share/cmsis-pack-manager


### WARN: multi-stage: run STAGE ###
FROM ubuntu:24.04 AS run

ARG TARGETPLATFORM

ARG GH_RUNNER_VERSION=2.335.1
ARG JLINK_VERSION=V876

LABEL org.opencontainers.image.ref.name=gh-runner
LABEL org.opencontainers.image.source=https://github.com/phoenix-rtos/phoenix-rtos-docker

ENV RUNNER_ALLOW_RUNASROOT=true
WORKDIR /actions-runner

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        wget \
        git \
        libhidapi-dev \
        libusb-1.0-0 \
        libicu-dev \
        python3 \
        uhubctl \
        libatomic1 \
        gdb-multiarch \
        net-tools \
    && rm -rf /var/lib/apt/lists/*

# install github actions runner
RUN if [ "$TARGETPLATFORM" = "linux/amd64" ]; then \
        GH_PLATFORM="x64"; \
    elif [ "$TARGETPLATFORM" = "linux/arm64" ]; then \
        GH_PLATFORM="arm64"; \
    else \
        echo "Unknown target platform: $TARGETPLATFORM" && exit 1; \
    fi; \
    curl -L -O https://github.com/actions/runner/releases/download/v${GH_RUNNER_VERSION}/actions-runner-linux-${GH_PLATFORM}-${GH_RUNNER_VERSION}.tar.gz \
    && tar -xzf ./actions-runner-linux-${GH_PLATFORM}-${GH_RUNNER_VERSION}.tar.gz \
    && rm -rf ./actions-runner-linux-${GH_PLATFORM}-${GH_RUNNER_VERSION}.tar.gz \
    && DEBIAN_FRONTEND=noninteractive ./bin/installdependencies.sh \
    && rm -rf /var/lib/apt/lists/*


# install Jlink tools for 64-bit arm architecture and 64-bit amd architecture
RUN if [ "$TARGETPLATFORM" = "linux/amd64" ]; then \
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

ENV PATH="/opt/SEGGER/JLink:${PATH}"

# copy all build-stage artifacts in a single layer
COPY --from=build /rootfs /
ENV PATH="/opt/phoenix/utils:/opt/venv/bin:${PATH}"

COPY entry.py .

ENTRYPOINT ["python3", "entry.py"]
CMD ["/actions-runner/bin/runsvc.sh"]
