WAMR_PATH=${1:-/opt/wasm-micro-runtime}

make clean
make TARGET_WASM=yes TARGET_INTEL_SGX=yes SGX_EMBEDDED_CONFIG=yes
$WAMR_PATH/wamr-compiler/build/wamrc -sgx --bounds-checks=0 -o src/mosquitto.aot src/mosquitto
echo "Now run $WAMR_PATH/product-mini/platforms/linux-sgx/enclave-sample/iwasm --addr-pool=0.0.0.0/32,0000:0000:0000:0000:0000:0000:0000:0000/64 --heap-size=4294967296 src/mosquitto.aot"