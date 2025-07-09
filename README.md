# static-openssl
This project provides a shell script that builds a fully static OpenSSL binary inside a Docker container. It uses a debian:bullseye image with musl-gcc to ensure that the resulting binary has no dynamic library dependencies, making it portable across nearly all Linux systems, including minimal or hardened OS's.

# Features

 - Builds OpenSSL 3.0.13 as a statically linked binary
 - Uses musl-gcc to eliminate reliance on glibc
 - Runs entirely inside Docker — no host system pollution
 - Final binary is less than ~6MB

Suitable for:

 - Alpine-based containers
 - Hardened distros with no dynamic loader
 - Minimal VMs or static security tools

# Requirements
 - Docker
 - Bash shell
 - Internet access to download OpenSSL source

No dependencies are required on the host system beyond Docker itself.

# To Run
Clone this repo and run:

`./build-static-openssl.sh`

This will:

1. Build a temporary Docker image
2. Compile OpenSSL using musl-gcc
3. Extract the final binary to ./dist/openssl

# Output
The built binary will be saved to:
`./dist/openssl`
You can copy and use this binary anywhere — even on minimal systems that lack /lib/ld-musl-x86_64.so.1 or /lib64/ld-linux-x86-64.so.2.

# Optional
If you want to build a different OpenSSL version, edit this line in the script:
`OPENSSL_VERSION="3.0.13"`

# Internals 
 - Dockerfile uses debian:bullseye
 - Installs musl-tools, build-essential, and dependencies
 - Compiles OpenSSL using:
 - `CC=musl-gcc ./Configure linux-x86_64 -static no-shared ...`
 - Strips and extracts the openssl binary using COPY --from stage

No support is offered for this work, if you spot any problems open up an issue for them
