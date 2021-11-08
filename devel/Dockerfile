FROM phoenixrtos/build:latest

# download python3 and qemu
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
    TARGET=host-pc make -C phoenix-rtos-hostutils -f Makefile.old all && \
    mkdir -p /opt/phoenix/utils && \
    (cd _build/host-pc/prog.stripped && cp phoenixd psu psdisk /opt/phoenix/utils) && \
    cd .. && rm -rf phoenix-rtos-project && \
    chmod -R a+rwX /opt/phoenix/utils

ENV PATH="/opt/phoenix/utils:${PATH}"

ENTRYPOINT ["/bin/bash", "-l", "-c"]
