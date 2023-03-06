# FROM rust:1.61.0 as builder
# WORKDIR /app
# COPY . .
# RUN cargo build
# RUN cargo build --release
# RUN ls 
#
# FROM alpine:3.17.2
# WORKDIR /app
# COPY --from=builder /app/target/release/rust_axum /rust_axum
# EXPOSE 3000
# CMD ["./rust_axum"]

# Using the `rust-musl-builder` as base image, instead of 
# the official Rust toolchain
FROM clux/muslrust:stable AS chef
USER root
RUN cargo install cargo-chef
WORKDIR /app

FROM chef AS planner
COPY . .
RUN cargo chef prepare --recipe-path recipe.json

FROM chef AS builder
COPY --from=planner /app/recipe.json recipe.json
# Notice that we are specifying the --target flag!
RUN cargo chef cook --release --target x86_64-unknown-linux-musl --recipe-path recipe.json
COPY . .
RUN cargo build --release --target x86_64-unknown-linux-musl --bin rust_axum 

FROM alpine AS runtime
RUN addgroup -S myuser && adduser -S myuser -G myuser
COPY --from=builder /app/target/x86_64-unknown-linux-musl/release/rust_axum /usr/local/bin/
USER myuser
EXPOSE 3000
CMD ["/usr/local/bin/rust_axum"]
