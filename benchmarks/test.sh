# alternative Path for WASI-SDK is the first arg
WASI_SDK_PATH=${1:-/opt}
# alternative Path for WAMR is the second arg
WAMR_PATH=${2:-/opt}

./build.sh $WASI_SDK_PATH $WAMR_PATH

WASI_SDK_PATH="$WASI_SDK_PATH/wasi-sdk"
WAMR_PATH="$WAMR_PATH/wasm-micro-runtime"

cp iwasm mosquitto-wasm/iwasm

cd mosquitto-wasm/test

cp -r ssl broker/ssl
cp -r ssl lib/ssl

cd broker
make clean
make TARGET_WASM=yes test-compile || exit 1
echo ">>> Run broker tests"
test_ids=(01 02 03 04 05 06 07 08 09 10 11 12 13 14)
for test_id in ${test_ids[@]}; do
    echo ">>> Run test $test_id"
    # if make $test_id fails, then exit
    make TARGET_WASM=yes $test_id || exit 1
done

echo ">>> Run library tests"
cd ../lib
make clean
make WAMR_PATH=$WAMR_PATH WASI_SDK_PATH=$WASI_SDK_PATH TARGET_WASM=yes test || exit 1

echo ">>> Run client tests"
cd ../client
make clean
make TARGET_WASM=yes test || exit 1