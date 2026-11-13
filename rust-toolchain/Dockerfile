ARG RUST_TOOLCHAIN_SOURCE=download

FROM ubuntu:24.04 AS base

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        jq \
        wget \
        xz-utils \
    && rm -rf /var/lib/apt/lists/*

FROM base AS download
ARG RUST_TOOLCHAIN
ARG RUST_TOOLCHAIN_URL
RUN set -ex; \
    test -n "$RUST_TOOLCHAIN" -a -n "$RUST_TOOLCHAIN_URL"; \
    mkdir /dist && cd /dist && \
    wget -q "$RUST_TOOLCHAIN_URL/$RUST_TOOLCHAIN.tar.xz" "$RUST_TOOLCHAIN_URL/$RUST_TOOLCHAIN.tar.xz.sha256"

FROM base AS local
ARG RUST_TOOLCHAIN
COPY --from=dist ${RUST_TOOLCHAIN}.tar.xz ${RUST_TOOLCHAIN}.tar.xz.sha256 /dist/

FROM ${RUST_TOOLCHAIN_SOURCE} AS fetch
ARG RUST_TOOLCHAIN
# cargo for toolchains built without --with-cargo; one matching the toolchain is preferred
ARG CARGO_VERSION=1.98.1

RUN set -ex; \
    cd /dist && sha256sum -c "$RUST_TOOLCHAIN.tar.xz.sha256" && \
    mkdir -p /opt/phoenix/rust && \
    tar xf "$RUST_TOOLCHAIN.tar.xz" --strip-components=1 -C /opt/phoenix/rust && \
    rm -rf /dist

RUN set -ex; \
    if [ ! -x /opt/phoenix/rust/bin/cargo ]; then \
        cargo="cargo-$CARGO_VERSION-x86_64-unknown-linux-gnu"; \
        cd /tmp && \
        wget -q "https://static.rust-lang.org/dist/$cargo.tar.xz" "https://static.rust-lang.org/dist/$cargo.tar.xz.sha256" && \
        sha256sum -c "$cargo.tar.xz.sha256" && \
        tar xf "$cargo.tar.xz" && \
        cp "$cargo/cargo/bin/cargo" /opt/phoenix/rust/bin/ && \
        jq --arg v "$CARGO_VERSION" '.cargo = {version: $v, source: "static.rust-lang.org"}' /opt/phoenix/rust/PHOENIX-TOOLCHAIN.json > /tmp/toolchain.json && \
        mv /tmp/toolchain.json /opt/phoenix/rust/PHOENIX-TOOLCHAIN.json && \
        rm -rf "$cargo" "$cargo.tar.xz" "$cargo.tar.xz.sha256"; \
    fi; \
    chmod -R a+rX /opt/phoenix/rust

FROM scratch
ARG RUST_TOOLCHAIN

LABEL org.opencontainers.image.ref.name=rust-toolchain
LABEL org.opencontainers.image.source=https://github.com/phoenix-rtos/phoenix-rtos-docker
LABEL org.opencontainers.image.version=${RUST_TOOLCHAIN}

COPY --from=fetch /opt/phoenix/rust /opt/phoenix/rust
