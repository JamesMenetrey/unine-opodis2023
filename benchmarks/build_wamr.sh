WAMR_PATH=${1:-/opt}
WORKDIR=$(pwd)

cd $WAMR_PATH/wasm-micro-runtime
# we use wamr 1.2.3
git checkout tags/WAMR-1.2.3

# set the heap size of the enclave to 512MB
sed -i 's/<StackMaxSize>0x100000</StackMaxSize>/<StackMaxSize>0x1000000</StackMaxSize>/g' $WAMR_PATH/wasm-micro-runtime/product-mini/platforms/linux-sgx/enclave-sample/Enclave/Enclave.config.xml
sed -i 's/<HeapMaxSize>0x8000000<\HeapMaxSize>/<HeapMaxSize>0x20000000<\HeapMaxSize>/g' $WAMR_PATH/wasm-micro-runtime/product-mini/platforms/linux-sgx/enclave-sample/Enclave/Enclave.config.xml
# switch from simulation mode to hardware mode
# but set prelease mode to true
sed -i 's/SGX_MODE ?= SIM/SGX_MODE ?= HW/g' $WAMR_PATH/wasm-micro-runtime/product-mini/platforms/linux-sgx/enclave-sample/Makefile
sed -i '/SPEC_TEST ?= 0/a SGX_PRERELEASE=1' $WAMR_PATH/wasm-micro-runtime/product-mini/platforms/linux-sgx/enclave-sample/Makefile
# set global heap pool to 980MB
GLOBAL_HEAP_POOL_SIZE=980000000

# Build WAMR
echo ">>> Build WAMR"
cd product-mini/platforms/linux
rm -r build
mkdir build
cd build
cmake -DWAMR_BUILD_AOT=1 -DWAMR_BUILD_GLOBAL_HEAP_POOL=1 -DWAMR_BUILD_GLOBAL_HEAP_SIZE=$GLOBAL_HEAP_POOL_SIZE ..
make
echo ">>> Build WAMR finished"

echo ">>> Build WAMR compiler"
cd $WAMR_PATH/wasm-micro-runtime/wamr-compiler/
./build_llvm.sh
rm -r build
mkdir build
cd build
cmake ..
make
echo ">>> Build WAMR compiler finished"

echo ">>> Build WAMR SGX"
cd $WAMR_PATH/wasm-micro-runtime/product-mini/platforms/linux-sgx
rm -r build
mkdir build
cd build
cmake -DWAMR_BUILD_AOT=1 -DWAMR_BUILD_LIB_PTHREAD=0 -DWAMR_BUILD_SIMD=1 -DWAMR_BUILD_GLOBAL_HEAP_POOL=1 -DWAMR_BUILD_GLOBAL_HEAP_SIZE=$GLOBAL_HEAP_POOL_SIZE -DWAMR_BUILD_LIB_RATS=1 ..
make
if [ $? -ne 0 ]; then
    echo ">>> Build WAMR SGX failed: Installed SGX-SDK already?"
fi
cd ../enclave-sample
make clean
make
echo ">>> Build WAMR SGX finished"

# copy iwasm from WAMR to mosquitto-wasm
cp $WAMR_PATH/wasm-micro-runtime/product-mini/platforms/linux/build/iwasm $WORKDIR/iwasm
cp $WORKDIR/iwasm $WORKDIR/