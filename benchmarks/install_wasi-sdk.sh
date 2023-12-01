# alternative Path for WASI-SDK is the first arg
WASI_SDK_PATH=${1:-/opt}

WASI_VERSION=20
WASI_FULL_VERSION=$WASI_VERSION.0

echo " >>> Installing WASI-SDK $WASI_FULL_VERSION to $WASI_SDK_PATH/wasi-sdk"

echo " >>> Installing wget"
# install wget
sudo apt-get update
sudo apt-get install -y wget

# Download WASI-SDK
echo " >>> Download WASI-SDK"
WASI_SDK=https://github.com/WebAssembly/wasi-sdk/releases/download/wasi-sdk-$WASI_VERSION/wasi-sdk-$WASI_FULL_VERSION-linux.tar.gz

wget $WASI_SDK

# Extract WASI-SDK into $WASI_SDK_PATH
echo " >>> Extract WASI-SDK into $WASI_SDK_PATH"
touch $WASI_SDK_PATH/wasi-sdk-test.txt
if [ $? -ne 0 ]; then
    sudo tar -xzf wasi-sdk-$WASI_FULL_VERSION-linux.tar.gz -C $WASI_SDK_PATH
    sudo ln -s $WASI_SDK_PATH/wasi-sdk-$WASI_FULL_VERSION $WASI_SDK_PATH/wasi-sdk
else
    rm $WASI_SDK_PATH/wasi-sdk-test.txt
    tar -xzf wasi-sdk-$WASI_FULL_VERSION-linux.tar.gz -C $WASI_SDK_PATH
    ln -s $WASI_SDK_PATH/wasi-sdk-$WASI_FULL_VERSION $WASI_SDK_PATH/wasi-sdk
fi
rm wasi-sdk-$WASI_FULL_VERSION-linux.tar.gz