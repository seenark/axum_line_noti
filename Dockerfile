# STAGE 1 is to build the binary
# Use rust-based image for container
FROM rust:1.68.0-alpine AS builder

# Adding necessary packages
RUN apk update
RUN apk add pkgconfig openssl openssl-dev musl-dev
RUN apk add --update qemu-x86_64
# RUN rustup target add aarch64-unknown-linux-musl
RUN rustup target add x86_64-unknown-linux-musl
# RUN rustup toolchain install stable-aarch64-unknown-linux-musl

# Set working directory in container; make directory if not exists
RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

# Copy all files from local computer to container
COPY Cargo.toml .
COPY Cargo.lock .
# COPY .env.docker .env
COPY src src

# Build release application
# RUN cargo build --target aarch64-unknown-linux-musl --release
RUN cargo build --target x86_64-unknown-linux-musl --release


# STAGE 2 is to have smallest image possible by including only necessary binary
# Use smallest base image
# FROM shinsenter/scratch

# Copy application binary from STAGE 1 image to STAGE 2 image
FROM busybox:musl
# rust_axum is app name that define in Cargo.toml
COPY --from=builder /usr/src/app/target/x86_64-unknown-linux-musl/release/rust_axum /bin/rust_axum

EXPOSE 8080

ENTRYPOINT ["/bin/rust_axum"]
