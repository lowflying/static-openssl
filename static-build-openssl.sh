#!/usr/bin/env bash
set -euo pipefail

OPENSSL_VERSION="3.0.13"
IMAGE_NAME="openssl-musl-static-builder"
CONTAINER_NAME="openssl-musl-extract"
BUILD_DIR="openssl-musl-build"
OUT_BINARY="openssl"

rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

cat > Dockerfile <<EOF
FROM debian:bullseye AS builder

ENV OPENSSL_VERSION=${OPENSSL_VERSION}

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
      build-essential musl-tools curl perl ca-certificates && \
    update-ca-certificates && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /build

RUN curl -LO https://www.openssl.org/source/openssl-\${OPENSSL_VERSION}.tar.gz && \
    tar -xzf openssl-\${OPENSSL_VERSION}.tar.gz && \
    cd openssl-\${OPENSSL_VERSION} && \
    CC=musl-gcc ./Configure linux-x86_64 -static \
      no-shared no-dso no-zlib no-module no-secure-memory no-afalgeng \
      --prefix=/opt/openssl-static && \
    make -j"\$(nproc)" build_programs && \
    strip apps/openssl && \
    mkdir -p /static && \
    cp apps/openssl /static/

FROM scratch
COPY --from=builder /static/openssl /openssl
EOF

# Local output dir
mkdir -p out

echo "Building Docker image..."
docker build -t "$IMAGE_NAME" .

echo "Creating temporary container to extract..."
docker create --name "$CONTAINER_NAME" "$IMAGE_NAME" /bin/sh

echo "Copying static OpenSSL binary..."
docker cp "$CONTAINER_NAME:/openssl" out/

echo "Cleaning up container..."
docker rm "$CONTAINER_NAME" > /dev/null

cd ..
mkdir -p dist
mv "$BUILD_DIR/out/$OUT_BINARY" dist/

echo "Done! Static OpenSSL binary saved to: ./dist/$OUT_BINARY"
