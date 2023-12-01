WORKDIR=$(pwd)

cd wolfssl

# install wolfSSL once to have the header files
sudo apt-get install -y autoconf automake libtool clang

# replace error by warning
sed -i 's/#error Cannot enable more than one multiple precision math library!/#warning Cannot enable more than one multiple precision math library!/g' wolfssl/wolfcrypt/settings.h

./autogen.sh
./configure --enable-ocsp --enable-nginx --enable-opensslall --enable-stunnel --enable-ra=yes --enable-keying-material
make
sudo make install
sudo ldconfig
make clean

cd $WORKDIR

cd wolfssl_build_files
./build-native-ra.sh
echo ">>> Installed native wolfssl"
./build-wasm-attestation.sh
echo ">>> Installed wasm wolfssl"

cd $WORKDIR