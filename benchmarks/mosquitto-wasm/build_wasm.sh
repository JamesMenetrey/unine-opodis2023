WAMR_PATH=${1:-/opt/wasm-micro-runtime}

make clean
make TARGET_WASM=yes
$WAMR_PATH/wamr-compiler/build/wamrc -o src/mosquitto.aot src/mosquitto
$WAMR_PATH/wamr-compiler/build/wamrc -o client/mosquitto_sub.aot client/mosquitto_sub
$WAMR_PATH/wamr-compiler/build/wamrc -o client/mosquitto_pub.aot client/mosquitto_pub
echo "Now run ./iwasm --allow-resolve=* --addr-pool=0.0.0.0/32,0000:0000:0000:0000:0000:0000:0000:0000/64 --heap-size=4294967296 --dir=. src/mosquitto.aot -c mosquitto.conf"