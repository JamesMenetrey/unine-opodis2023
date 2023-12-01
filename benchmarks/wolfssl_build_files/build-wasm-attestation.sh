#!/bin/bash

cd wasm-attestation
make clean
make

mkdir -p ../../mosquitto-wasm/build_deps
cp libwolfssl.a ../../mosquitto-wasm/build_deps/libwolfssl.a
make clean