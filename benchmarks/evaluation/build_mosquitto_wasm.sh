WAMR_PATH=${1:-/opt}
WAMR_PATH=$WAMR_PATH/wasm-micro-runtime

cd ./../mosquitto-wasm

make clean
make TARGET_WASM=yes WITH_WOLFSSL=yes

$WAMR_PATH/wamr-compiler/build/wamrc -o src/mosquitto.aot src/mosquitto
cp src/mosquitto.aot ./../evaluation/mosquitto-wasm.aot

echo "mosquitto-wasm.aot was built successfully, run:"
echo "./iwasm --allow-resolve=* --addr-pool=0.0.0.0/32,0000:0000:0000:0000:0000:0000:0000:0000/64 --heap-size=4294967296 --dir=. mosquitto-wasm.aot -c mosquitto.conf"

cd ../evaluation