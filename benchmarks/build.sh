WORKDIR=$(pwd)
# alternative Path for WASI-SDK is the first arg
WASI_SDK_PATH=${1:-/opt}
# alternative Path for WAMR is the second arg
WAMR_PATH=${2:-/opt}

WASI_SDK_PATH="$WASI_SDK_PATH/wasi-sdk"
WAMR_PATH="$WAMR_PATH/wasm-micro-runtime"

cd mosquitto-wasm

make clean
make WAMR_PATH=$WAMR_PATH WASI_SDK_PATH=$WASI_SDK_PATH TARGET_WASM=yes WITH_WOLFSSL=yes || exit 1
echo ">>> Built mosquitto-wasm"
echo ">>> Create *.aot files, this might take a while..."
$WAMR_PATH/wamr-compiler/build/wamrc -o src/mosquitto.aot src/mosquitto
$WAMR_PATH/wamr-compiler/build/wamrc -o client/mosquitto_sub.aot client/mosquitto_sub
$WAMR_PATH/wamr-compiler/build/wamrc -o client/mosquitto_pub.aot client/mosquitto_pub

cd $WORKDIR
echo "built mosquitto-wasm"

# delete old executables if exist
rm mosquitto_sub mosquitto_pub mosquitto

# copy executables into corresponding folders
cp mosquitto-wasm/client/mosquitto_sub.aot ./mosquitto_sub
cp mosquitto-wasm/client/mosquitto_pub.aot ./mosquitto_pub
cp mosquitto-wasm/src/mosquitto.aot ./mosquitto

# create certificates
./gen_certs.sh