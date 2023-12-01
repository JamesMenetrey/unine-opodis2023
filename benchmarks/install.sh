# alternative Path for WASI-SDK is the first arg
WASI_SDK_PATH=${1:-/opt}
# alternative Path for WAMR is the second arg
WAMR_PATH=${2:-/opt}

WORKDIR=$(pwd)

# check if WASI-SDK is already installed
if [ -d "$WASI_SDK_PATH/wasi-sdk" ]; then
    echo "WASI-SDK is already installed"
else
    # install WASI-SDK
    ./install_wasi-sdk.sh $WASI_SDK_PATH
fi

cd $WORKDIR

# check if wamr is already installed
if [ -d "$WAMR_PATH/wasm-micro-runtime" ]; then
    echo "WAMR is already installed"
else
    # install wamr by calling install_wamr.sh
    echo "Install WAMR"
    ./install_wamr.sh $WAMR_PATH
fi

cd $WORKDIR

# install wolfSSL
./install_wolfssl.sh
