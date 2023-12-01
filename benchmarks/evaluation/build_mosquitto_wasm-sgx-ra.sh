WAMR_PATH=${1:-/opt}
WAMR_PATH=$WAMR_PATH/wasm-micro-runtime
rm -r ./../mosquitto-wasm/certs
cp -r certs ./../mosquitto-wasm/certs
cp mosquitto.conf ./../mosquitto-wasm/mosquitto.conf

cd ./../mosquitto-wasm

make clean
make TARGET_WASM=yes TARGET_INTEL_SGX=yes WITH_WOLFSSL=yes SGX_EMBEDDED_CONFIG=yes WITH_ATTESTATION=yes WITH_BROKER_ATTESTATION=yes || exit 1

$WAMR_PATH/wamr-compiler/build/wamrc -sgx --bounds-checks=0 -o src/mosquitto-sgx.aot src/mosquitto
cp src/mosquitto-sgx.aot ./../evaluation/mosquitto-sgx.aot

echo "mosquitto-sgx.aot was built successfully, run:"
echo "$WAMR_PATH/product-mini/platforms/linux-sgx/enclave-sample/iwasm --addr-pool=0.0.0.0/32,0000:0000:0000:0000:0000:0000:0000:0000/64 --heap-size=4294967296 mosquitto-sgx.aot"

cd ../evaluation
