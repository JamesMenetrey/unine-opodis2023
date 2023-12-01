#!/bin/bash

cd native-ra
sudo rm -r /usr/local/include/wolfssl
sudo rm -r /usr/local/lib/libwolfssl*
make clean
make

sudo cp -r ../../wolfssl/wolfssl /usr/local/include/wolfssl
sudo cp libwolfssl.so /usr/local/lib/libwolfssl.so
sudo ldconfig