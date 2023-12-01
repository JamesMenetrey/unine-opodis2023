# Evaluation
This folder contains multiple evaluation scenarios and scripts that should help to run the evaluation scenarios. The goal is to provide an easy way to reproduce the obtained results.

# Case Description

## Case 1: Connecting clients
Case 1 tests the connection latency of a new client to the broker, i.e. the speed to make the TLS handshake and to register a new MQTT client.
Case 1 has two different scenarios in itself:
* Ephemeral Diffie-Hellman key exchange: no pre-shared keys
* Preshared-key mode: Server and Client have agreed upfront on a pre-shared key

Additionally, you can tell the client to request attestation evidence during the handshake, i.e. attesting the broker genuineness.

### Build params
All build params can be specified in the `case_1/Makefile`.
* `HOST_NAME`: Hostname the client it should connect to
* `WITH_ATTESTATION` and `HAVE_REMOTE_ATTESTATION`: Pass those parameters to request attestation evidence.
* `WITH_PSK`: Pass this parameter to use preshared keys.

Before building the client, make sure to have built and installed the native Mosquitto library on the client machine as the client code relies on this library. To do so, run

```bash
cd evaluation
./build_mosquitto_native.sh
```

Now you can build the client using
````bash
cd evaluation/case_1
make clean && make
````

## Case 2: Message latency
All cases in folder `case_2` are related to message latency. There are three different cases.

### Build params
Before building, you should specify the ``HOST_NAME`` (as in case_1):
* `HOST_NAME`: Hostname the client it should connect to 

Before building the client, make sure to have built and installed the native Mosquitto library on the client machine as the client code relies on this library. To do so, run

```bash
cd evaluation
./build_mosquitto_native.sh
```

Now you can build all cases once by running
````bash
cd evaluation/case_2
make clean && make
````

### Case message rate scaling
In this case, the number of subscribers and publishers is fixed but the message rate increases.
The preset parameters are:
* 1 subscriber
* 1 publisher
* message rate from 1 / s to 200 / s

### Case subscriber scaling
In this case, the number of publishers and the message rate is fixed but the number of subscribers is fixed. However, the subscribers all create a shared subscription (new feature in MQTT v5)
The preset parameters are:
* 1 publisher
* 25 messages / second
* up to 256 subscribers

### Case publisher scaling
In this case, the number of subscribers is fixed as is the message rate. The number of publishers will increase.
The preset parameters are:
* 25 subscribers
* 5 messages / second (and publisher)
* up to 64 publishers

## Prepare environment
Now, if you are testing locally, certificates should be fine. Otherwise you need to setup your TLS certificates the same way as for the broker (described below). Note, that broker's CA should be known to the client's CA and vice versa. 

Additionally, if you run a case that involves messages publishing, you need to prepare the random data by running
````bash
cd evaluation
./generate_random.sh
````

# Build Brokers
In order to build the various broker variants, you have to first prepare the build dependencies. Those include
1. run the `install_wolfssl.sh` in the root of the project
2. generate certificates for clients and brokers by running `gen_certs.sh` in the root of the project
3. copy the `certs` folder in the `evaluation` folder, i.e. the certificates are then located in `evaluation/certs`
4. generate the `psk_file` that is used to be embedded in the config. For this, run the `gen_psk_file.sh` script in the `evaluation` folder
5. Adapt the server address in the file `evaluation/mosquitto.conf` for all listeners

Now you can build the broker variants. There is a script for each broker:
1. native variant: `build_mosquitto_native.sh` (use `build_mosquitto_native-ra.sh` if you wish to use on the client side remote attestation, requires a supporting wolfSSL build)
2. wasm variant: `build_mosquitto_wasm.sh`
3. sgx variant: `build_mosquitto_wasm-sgx.sh` (use `build_mosquitto_wasm-sgx-ra.sh` if you wish the broker to support remote attestation, requires a supporting wolfSSL build)

# Run a case
First, you will have to manually start the broker by running
```bash
./start_broker <BROKER-VARIANT>
```
Broker-Variant must be one of the following numbers

* 0: native mosquitto
* 1: mosquitto wasm
* 2: mosquitto sgx (wasm)

Next, start the scenario by calling
```bash
./run_evaluation_scenario <case_no> <case_name>
```
Case number must be one of the existing cases (case 1 or case 2, i.e. either <1> or <2>).
Case name can be freely choosen. It will be used to export your results. At runtime the results are collected into the folder `results` but at the end, the results will be copied into a folder called `results_$case_name` to avoid overwriting of your own results. 

Please note: The scripts will stop on their own (except for the broker process), but when it logs that it stops, it usually waits for around 15 seconds to ensure all data has been saved. So be patient...

# Troubleshooting

## Building a scenario
1. Do you have Mosquitto native built and installed on the machine where the clients are running?

## Running a scenario
1. Do you have random data setup?
2. Are Hostnames / Addresses correct?
3. Are the certificates correctly setup? This includes ca.crt file as well as server.key, server.crt and if applicable client.key and client.crt

## Building SGX
1. Are the certificates correctly setup? This includes ca.crt file as well as server.key, server.crt and if applicable client.key and client.crt
2. Is the psk_file.txt existing in the `evaluation/certs` folder?
3. Is IntelSGX correctly setup and all necessary dependencies installed?
4. Is WAMR and WASI-SDK at the default path? Note: While the base scenarios in the root of this project should work with any path, the scenarios here require them to be at their default place (i.e. `/opt/wasi-sdk` for `WASI` and `/opt/wasm-micro-runtime` for `WAMR`)