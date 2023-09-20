### WARN: multi-stage: BUILD STAGE ###
FROM ubuntu:22.04 as build

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
        libusb-1.0 \
        gcc \
        gdb-multiarch \
        git \
        libtool \
        make \
        pkgconf \
        python3-dev \
        python3-pip \
        python3-venv \
        tclsh \
        wget \
    && rm -rf /var/lib/apt/lists/*


# install openocd in 0.12 version
RUN mkdir -p /etc/udev/rules.d && \
    git clone https://github.com/openocd-org/openocd.git --branch v0.12.0 && \
    cd openocd && \
    ./bootstrap && \
    ./configure --enable-stlink && make install -j 9 && \
    cp contrib/60-openocd.rules /etc/udev/rules.d/ && \
    cd ../ && rm -rf openocd


# use to check-out specific commit of phoenix-rtos-project (--build-arg PHOENIX_PROJECT_REF=release/3.0)
ARG PHOENIX_PROJECT_REF=HEAD

# install hostutils
RUN git clone --recursive https://github.com/phoenix-rtos/phoenix-rtos-project.git && \
    cd phoenix-rtos-project && \
    git checkout ${PHOENIX_PROJECT_REF} && \
    NOSAN=1 TARGET=host-generic-pc ./phoenix-rtos-build/build.sh host && \
    mkdir -p /opt/phoenix/utils && \
    git rev-parse --short HEAD > /opt/phoenix/utils/git-version && \
    (cd _build/host-generic-pc/prog.stripped && cp -a * /opt/phoenix/utils) && \
    cd .. && rm -rf phoenix-rtos-project && \
    chmod -R a+rX /opt/phoenix/utils

ENV PATH="/opt/phoenix/utils:${PATH}"

# prepare virtual env for test runner
RUN python3 -m venv /opt/venv

ENV PATH="/opt/venv/bin:$PATH"

# install test runner python requirements
# TODO: use requirements.txt from phoenix-rtos-test ?
RUN pip3 install --no-cache-dir \
    pyserial \
    pyyaml \
    pexpect \
    RPi.GPIO \
    colorama \
    junitparser


### WARN: multi-stage: run STAGE ###
FROM ubuntu:22.04 as run

ARG TARGETPLATFORM

ARG GH_RUNNER_VERSION=2.309.0

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
        python3-dev \
        python3-pip \
        xz-utils \
        uhubctl \
        libatomic1 \
        gdb-multiarch \
    && rm -rf /var/lib/apt/lists/*

# install github actions runner
RUN curl -L -O https://github.com/actions/runner/releases/download/v${GH_RUNNER_VERSION}/actions-runner-linux-${GH_PLATFORM}-${GH_RUNNER_VERSION}.tar.gz \
    && tar -xzf ./actions-runner-linux-${GH_PLATFORM}-${GH_RUNNER_VERSION}.tar.gz \
    && rm -rf ./actions-runner-linux-${GH_PLATFORM}-${GH_RUNNER_VERSION}.tar.gz \
    && DEBIAN_FRONTEND=noninteractive ./bin/installdependencies.sh \
    && rm -rf /var/lib/apt/lists/*


ARG JLINK_VERSION=V792d

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

ENV PATH="/opt/SEGGER/JLink:${PATH}"


# get phoenix-rtos host utils
COPY --from=build /opt/phoenix/utils /opt/phoenix/utils
ENV PATH="/opt/phoenix/utils:${PATH}"

# get openocd
COPY --from=build /usr/local/bin/openocd /usr/local/bin
COPY --from=build /usr/local/share/openocd /usr/local/share/openocd

# get virtual env for runner
COPY --from=build /opt/venv /opt/venv
ENV PATH="/opt/venv/bin:${PATH}"

# install requests for entry.py
RUN pip3 install --no-cache-dir \
    requests

COPY entry.py .

ENTRYPOINT ["python3", "entry.py"]
CMD ["/actions-runner/bin/runsvc.sh"]
