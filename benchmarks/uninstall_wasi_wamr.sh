WASI_PATH=${1:-/opt}
WAMR_PATH=${2:-/opt}

WASI_VERSION=20

echo "Uninstalling WASI-SDK $WASI_VERSION from $WASI_PATH"
echo "Uninstalling WAMR from $WAMR_PATH"

# remove WASI-SDK
sudo rm -rf $WASI_PATH/wasi-sdk > /dev/null
sudo rm -rf $WASI_PATH/wasi-sdk-$WASI_VERSION > /dev/null

# remove WAMR
sudo rm -rf $WAMR_PATH/wamr > /dev/null

echo "Uninstalling dependencies"

sudo rm /etc/apt/sources.list.d/kitware.list > /dev/null

sudo apt remove apt-transport-https apt-utils build-essential \
  ca-certificates curl g++-multilib git gnupg \
  libgcc-9-dev lib32gcc-9-dev lsb-release \
  ninja-build ocaml ocamlbuild python2.7 \
  software-properties-common tree tzdata \
  unzip valgrind vim wget zip make openssl libssl-dev cmake kitware-archive-keyring > /dev/null

sudo apt autoremove > /dev/null

sudo apt-get update > /dev/null

echo "Uninstalling dependencies finished"