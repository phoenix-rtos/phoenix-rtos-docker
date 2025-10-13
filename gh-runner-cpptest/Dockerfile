FROM ubuntu:24.04

ARG TARGETPLATFORM

ARG GH_RUNNER_VERSION=2.320.0
ARG REVIEWDOG_VERSION=0.20.3

LABEL org.opencontainers.image.ref.name=gh-runner-cpptest
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
        libicu-dev \
        python3-dev \
        python3-pip \
        python3-venv \
        xz-utils \
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


# get cpptest 
COPY --from=parasoft/cpptest:2024.2 --chown=runner /opt/parasoft/cpptest /opt/parasoft/cpptest
ENV PATH="/opt/parasoft/cpptest:${PATH}"

# install reviewdog 
RUN curl -sfL https://raw.githubusercontent.com/reviewdog/reviewdog/fd59714416d6d9a1c0692d872e38e7f8448df4fc/install.sh | sh -s v${REVIEWDOG_VERSION}

# prepare virtual env for test runner
RUN python3 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# install requests for entry.py
RUN pip3 install --no-cache-dir \
    requests

COPY entry.py .

ENTRYPOINT ["python3", "entry.py"]
CMD ["/actions-runner/bin/runsvc.sh"]
