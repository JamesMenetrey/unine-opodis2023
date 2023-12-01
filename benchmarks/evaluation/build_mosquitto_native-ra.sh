cd ./../mosquitto-wasm

sudo make uninstall
make clean
make WITH_THREADING=yes WITH_ATTESTATION=yes WITH_WOLFSSL=yes
sudo make install

cp src/mosquitto ./../evaluation/mosquitto-native

echo "mosquitto-native was built successfully, run:"
echo "./mosquitto-native -c mosquitto.conf"