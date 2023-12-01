WAMR_PATH=${1:-/opt}

WORKDIR=$(pwd)

echo ">>> Installing WAMR to $WAMR_PATH/wasm-micro-runtime"

# first try to write a simple file to check permissions
touch $WAMR_PATH/wamr-test.txt
if [ $? -ne 0 ]; then
    # call yourself with sudo
    echo "WAMR install dir requires sudo permissions"
    echo "Running install script as sudo"
    sudo ./install_wamr.sh $WAMR_PATH
    exit 0
fi
rm $WAMR_PATH/wamr-test.txt

# install dependencies (see see https://wamr.gitbook.io/document/basics/getting-started/host_prerequsites)
echo ">>> Installing dependencies"
sudo apt-get update

sudo apt-get install -y libgcc-9-dev lib32gcc-9-dev
# if it failed
if [ $? -ne 0 ]; then
    # add gcc-9 repo
    sudo add-apt-repository ppa:ubuntu-toolchain-r/test
    sudo apt-get update
    sudo apt-get install -y libgcc-9-dev lib32gcc-9-dev
fi

sudo apt-get install -y apt-transport-https apt-utils build-essential \
  ca-certificates curl g++-multilib git gnupg \
  lsb-release \
  ninja-build ocaml ocamlbuild python2.7 \
  software-properties-common tree tzdata \
  unzip valgrind vim wget zip make openssl libssl-dev --no-install-recommends

# additional dependencies for wamrc-compiler
sudo apt-get -y install python3-pip ccache

sudo wget --progress=dot:giga -O - https://apt.kitware.com/keys/kitware-archive-latest.asc | gpg --dearmor - | tee /usr/share/keyrings/kitware-archive-keyring.gpg 
sudo echo 'deb [signed-by=/usr/share/keyrings/kitware-archive-keyring.gpg] https://apt.kitware.com/ubuntu/ bionic main' | tee /etc/apt/sources.list.d/kitware.list
sudo apt-get update
sudo rm /usr/share/keyrings/kitware-archive-keyring.gpg
sudo apt-get install -y kitware-archive-keyring --no-install-recommends
sudo apt-get install -y cmake --no-install-recommends


# Clone WAMR
echo ">>> Clone WAMR"
cd $WAMR_PATH
git clone https://github.com/bytecodealliance/wasm-micro-runtime.git
git config --global --add safe.directory $WAMR_PATH/wasm-micro-runtime

cd $WORKDIR
# Build WAMR
echo ">>> Build WAMR"
./build_wamr.sh $WAMR_PATH