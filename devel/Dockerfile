FROM phoenixrtos/build:latest

# download python3 and qemu
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
        python3 \
        python3-pip \
	opensbi \
	qemu-system-i386 \
	qemu-system-misc \
	qemu-utils \
	u-boot-qemu \
    && rm -rf /var/lib/apt/lists/*

# get python requirements
RUN pip3 install --no-cache-dir \
	pyserial \
	pyyaml \
	pexpect

ENTRYPOINT ["/bin/bash", "-l", "-c"]
