# Mosquitto Wasm Playground
This repository serves as collection of scripts and other stuff to play with the WASM version of mosquitto.

## Setup Host Machine

### Setup IntelSGX
If you would like to make use of IntelSGX i.e. run Mosquitto within an Enclave, you have to first install Intel SGX SDK.

Please follow the instructions here: https://download.01.org/intel-sgx/latest/linux-latest/docs/Intel_SGX_SW_Installation_Guide_for_Linux.pdf

If you do not install it the installation script described below will not build the wamr runtime for sgx and log an error like

```>>> Build WAMR SGX failed: Installed SGX-SDK already?```

but it will resume installation anyway.

### Install Script
In order to be able to build and run mosquitto, you will have to install `wasi-sdk`, `wolfSSL`, and build `wamr`. You can do this by running
```bash
./install.sh
```
This will install `wasi-sdk` and `wamr`.

By default, this will install `wasi-sdk` and `wamr` in `/opt` which is in most cases the right place. However, if you like to install it at a different place, you can run the script as follows
```bash
./install.sh $WASIPATH $WAMRPATH
```
Note, if you already have installed `wasi-sdk` and / or `wamr`, please provide the folder where the folder of the corresponding installation is located.
For example, if you have installed `wasi-sdk` already in `~/wasi-sdk` then just pass `~/` as `wasi-sdk` path. The folder itself must be called 
* `wasi-sdk` for `wasi-sdk`
* `wasm-micro-runtime` for `wamr`

You can also install each dependency on its own. Just keep in mind, that `wamr` depends on `wasi-sdk`

```bash
./install_wasi-sdk.sh
./install_wamr.sh
./install_wolfssl.sh
./build_wamr.sh
```

Additionally, it will copy the built `iwasm` for you into the root of this folder.

Now your host machine should be setup!

## Build mosquitto
To build mosquitto, you should now just have to run
```bash
./build.sh
```
This will build mosquitto broker and clients, copy the binaries into this root folder and generate some certificates under `/certs`.

If you already installed WASI and WAMR at a different location than default, please run
```bash
./build.sh $WASIPATH $WAMRPATH
```

## Run a scenario
There are different scenarios you can try out. The scenarios are intended for demonstrative purposes and not as tests. All use the same binaries you built in the step before. Make sure that the `iwasm` binary is located in the root of this project and is executable.

### Scenario Ok
This scenario demonstrates the broker in a "correct" state: All certificates are accepted and correct. Run it with 

```bash
./scenario_ok.sh
```

Demonstrated features include
* SYS topics, where the broker sends information about how many messages he has sent since startup
* connecting client with TLS without certificate
* connecting clients with TLS with certificate

The expected output should look similar to the following (time will be different and some statements might be in a different order):
```bash
13:41:44: mosquitto version 2.0.15 starting
13:41:44: Config loaded from mosquitto.conf.
13:41:44: Opening ipv4 listen socket on port 8883.
13:41:44: Opening ipv4 listen socket on port 8883.
13:41:44: Opening ipv6 listen socket on port 8883.
13:41:44: Opening ipv4 listen socket on port 8884.
13:41:44: Opening ipv4 listen socket on port 8884.
13:41:44: Opening ipv6 listen socket on port 8884.
13:41:44: Opening ipv4 listen socket on port 1888.
13:41:44: Opening ipv6 listen socket on port 1888.
13:41:44: mosquitto version 2.0.15 running
Create some valid subscribers.
Number of sent messages since broker start will be logged every 5 seconds!.
13:41:49: New connection from 127.0.0.1:52046 on port 8884.
13:41:49: New connection from 127.0.0.1:50266 on port 1888.
13:41:49: New client connected from 127.0.0.1:50266 as auto-889F88B2-EB13-84DF-30BE-09C3564B1AD9 (p2, c1, k60).
13:41:49: New connection from 127.0.0.1:59300 on port 8883.
0
13:41:51: New client connected from 127.0.0.1:52046 as auto-D355B411-7E79-F476-9A49-A6F65F1C5754 (p2, c1, k60).
4
Starting a few publishers...
13:41:52: New client connected from 127.0.0.1:59300 as auto-7067AA36-9F13-77A2-DA12-3AC8CBFB1E04 (p2, c1, k60, u'CN=eiger-1, OU=CS, O=Unine, L=NE, ST=NE, C=CH').
13:41:53: New connection from 127.0.0.1:58806 on port 8883.
13:41:55: New client connected from 127.0.0.1:58806 as auto-8543C53D-0D8F-51FB-B9B9-D0FB1B6963BB (p2, c1, k60, u'CN=eiger-1, OU=CS, O=Unine, L=NE, ST=NE, C=CH').
Message to test topic with client cert and on localhost
13:41:55: Client auto-8543C53D-0D8F-51FB-B9B9-D0FB1B6963BB disconnected.
Message to test topic with client cert and on localhost
13:41:55: New connection from 127.0.0.1:59304 on port 8883.
13:41:56: New client connected from 127.0.0.1:59304 as auto-F761603F-9B88-DB9B-C743-E3E3078233A8 (p2, c1, k60, u'CN=eiger-1, OU=CS, O=Unine, L=NE, ST=NE, C=CH').
Message to test topic with client cert and on eiger-1
13:41:56: Client auto-F761603F-9B88-DB9B-C743-E3E3078233A8 disconnected.
Message to test topic with client cert and on eiger-1
14
Starting a few publishers without client cert...
13:42:01: New connection from 127.0.0.1:43802 on port 8884.
13:42:02: New client connected from 127.0.0.1:43802 as auto-8ED0E6DC-2135-DE92-B66C-431BA42DB729 (p2, c1, k60).
Message to test topic without client cert and on localhost
13:42:02: Client auto-8ED0E6DC-2135-DE92-B66C-431BA42DB729 disconnected.
Message to test topic without client cert and on localhost
13:42:02: New connection from 127.0.0.1:38120 on port 8884.
13:42:03: New client connected from 127.0.0.1:38120 as auto-CD9F77A7-333F-F7BB-2F83-D6645299A398 (p2, c1, k60).
Message to test topic without client cert and on eiger-1
13:42:03: Client auto-CD9F77A7-333F-F7BB-2F83-D6645299A398 disconnected.
Message to test topic without client cert and on eiger-1
21
Number of messages sent since broker start: 
22
Kill subscribers
Kill broker
```

### Scenario invalid certs
This scenario will demonstrate TLS errors

```bash
./scenario_errors.sh
```

Demonstrated features include
* Client rejects certificate of server
    * unknown ca
    * invalid cn
    * expired cert
* Server rejects certificate of client
    * unknown ca
    * expired cert

The expected output should look similar to the following (time will be different and some statements might be in a different order):
```bash
13:43:11: mosquitto version 2.0.15 starting
13:43:11: Config loaded from mosquitto.conf.
13:43:11: Opening ipv4 listen socket on port 8883.
13:43:11: Opening ipv4 listen socket on port 8884.
13:43:11: Opening ipv6 listen socket on port 8884.
13:43:11: Opening ipv4 listen socket on port 8885.
13:43:11: mosquitto version 2.0.15 running
Client with expired certificate tries to connect
13:43:16: New connection from 127.0.0.1:56416 on port 8883.
13:43:17: OpenSSL Error[0]: ASN date error, current date after
13:43:17: OpenSSL Error[1]: ASN date error, current date after
13:43:17: OpenSSL Error[2]: ASN date error, current date after
13:43:17: Client <unknown> disconnected: Protocol error.
Error: Protocol error
Client with invalid certificate tries to connect
13:43:19: New connection from 127.0.0.1:50226 on port 8883.
13:43:20: OpenSSL Error[0]: unknown error number
13:43:20: OpenSSL Error[1]: received alert fatal error
13:43:20: Client <unknown> disconnected: Protocol error.
Error: Protocol error
Client rejects expired server cert (client runs in debug mode to see the error)
13:43:22: New connection from 127.0.0.1:35478 on port 8884.
Client null sending CONNECT
OpenSSL Error[0]: ASN date error, current date after
OpenSSL Error[1]: ASN date error, current date after
OpenSSL Error[2]: ASN date error, current date after
13:43:23: OpenSSL Error[0]: unknown error number
13:43:23: OpenSSL Error[1]: received alert fatal error
13:43:23: Client <unknown> disconnected: Protocol error.
Error: Protocol error
Client reject server cert of unknown ca (client runs in debug mode to see the error)
13:43:25: New connection from 127.0.0.1:50234 on port 8883.
Client null sending CONNECT
OpenSSL Error[0]: certificate verify failed
OpenSSL Error[1]: certificate verify failed
OpenSSL Error[2]: certificate verify failed
13:43:26: OpenSSL Error[0]: unknown error number
13:43:26: OpenSSL Error[1]: received alert fatal error
13:43:26: Client <unknown> disconnected: Protocol error.
Error: Protocol error
Client reject server cert due to failing hostname validation (client runs in debug mode to see the error)
13:43:28: New connection from 127.0.0.1:46494 on port 8885.
Client null sending CONNECT
OpenSSL Error[0]: peer subject name mismatch
OpenSSL Error[1]: peer subject name mismatch
OpenSSL Error[2]: peer subject name mismatch
13:43:29: OpenSSL Error[0]: unknown error number
13:43:29: OpenSSL Error[1]: received alert fatal error
13:43:29: Client <unknown> disconnected: Protocol error.
Error: Protocol error
Kill broker
```

### Scenario load
The load scenario aims to simulate the broker's capabilities under load. There can be done a lot of fine tuning here to increase the maximum load  (e.g. using preshared keys, no mutual authentication, QoS level, etc.). However, the scenario should serve as basic demonstration.

You can run the scenario by executing
```bash
./scenario_load.sh
```
All subscribers will log there output (i.e. the messages they received) into `./logs` directory. There are 3 types of clients:
* one with a wild card subscription on all `test` topics and its subtopics
* one with a subscription on `test/a`
* one with a subscription on `test/b`

The log output serves as "quick validation" to check whether the subscribers got all the messages they should.

Obviousely, the clients with the wild card subscription will receive more messages than the other two types. 
There are two parameters where you can tune a bit the number of subscribers per topic as well as the number of messages per topic published.
```bash
./scenario_load.sh ${number_of_subscribers_per_topic} ${number_of_messages_per_topic}
```

Note, that the publishers are synchronized: They run all after each other.

The expected output should look similar to the following (time will be different and some statements might be in a different order):
```bash
Number of subscribers per topic 5
Number of messages per topic 5
Create 5 subscribers for general topic 'test'.
Create 5 subscribers for topic 'test/a'.
Create 5 subscribers for topic 'test/b'.
Publish to 'test/c'.
Publish to 'test/a'.
Publish to 'test/b'.
```

Additionally, you can find in the `logs` folder the output each subscriber received and verify if all messages have been delivered.

### Creating your own scenario
You can easily generate your own scenario by creating mosquitto.conf file the broker will consume. Familiarize yourself with the [mosquitto.conf](https://mosquitto.org/man/mosquitto-conf-5.html) syntax and semantics and the [available system topics](https://mosquitto.org/man/mosquitto-8.html) to subscribe to.

**Please be aware**, that running the other scenarios will lead to the deletion of `mosquitto.conf` file!

Start the corresponding subscribers and publishers after starting the broker. Stop the subscribers when you are done, as they will try to reconnect to the broker and won't stop when the connection is lost / the broker is not reachable!

## Run tests
To run the mosquitto built-in tests, execute
```bash
./test.sh $WASIPATH $WAMRPATH
```
This will (re)build the broker and then first execute the broker integration tests, followed by the library test and the client tests. If one test fails, the whole suite stops running.

Please check for details for tests in the `mosquitto-wasm/README-tests.md`.

# Evaluation
In the folder evaluation, there is the code for 4 evaluation secenarios to evaluate the performance differences between native, wasm, and sgx variant. Head to the `evaluation/README.md` for details.

# Troubleshooting
If you have troubles setting up the workspace, please check carefully the errors you obtain when running the various scripts. Issues can be related to
* Packages that do not exist on your distribution in the default repository
* Missing access rights to Git repositories