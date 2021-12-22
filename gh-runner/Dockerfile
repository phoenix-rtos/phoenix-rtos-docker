FROM ubuntu:20.04

ARG GH_RUNNER_VERSION=2.286.0
ARG GH_PLATFORM=arm

ENV RUNNER_ALLOW_RUNASROOT=true

WORKDIR /actions-runner

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        git \
        libhidapi-dev \
        python3-dev \
        python3-pip \
        xz-utils \
        uhubctl \
        libatomic1 \
    && rm -rf /var/lib/apt/lists/*

# install github actions runner
RUN curl -L -O https://github.com/actions/runner/releases/download/v${GH_RUNNER_VERSION}/actions-runner-linux-${GH_PLATFORM}-${GH_RUNNER_VERSION}.tar.gz \
    && tar -xzf ./actions-runner-linux-${GH_PLATFORM}-${GH_RUNNER_VERSION}.tar.gz \
    && rm -rf ./actions-runner-linux-${GH_PLATFORM}-${GH_RUNNER_VERSION}.tar.gz \
    && DEBIAN_FRONTEND=noninteractive ./bin/installdependencies.sh \
    && rm -rf /var/lib/apt/lists/*

# get phoenix-rtos host utils
COPY --from=phoenixrtos/devel /opt/phoenix/utils /opt/phoenix/utils
ENV PATH="/opt/phoenix/utils:${PATH}"

# get virtual env for runner
COPY --from=phoenixrtos/devel /opt/venv /opt/venv
ENV PATH="/opt/venv/bin:${PATH}"

# install requests for entry.py
RUN pip3 install --no-cache-dir \
    requests

COPY entry.py .

ENTRYPOINT ["python3", "entry.py"]
CMD ["/actions-runner/bin/runsvc.sh"]
