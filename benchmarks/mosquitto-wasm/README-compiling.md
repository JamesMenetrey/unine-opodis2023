The following packages can be used to add features to mosquitto. All of them
are optional.

* openssl
* c-ares (for DNS-SRV support, disabled by default)
* tcp-wrappers (optional, package name libwrap0-dev)
* libwebsockets (optional, disabled by default, version 2.4 and above)
* cJSON (optional but recommended, for dynamic-security plugin support, and
  JSON output from mosquitto_sub/mosquitto_rr)
* libsystemd-dev (optional, if building with systemd support on Linux)
* On Windows, a pthreads library is required if threading support is to be
  included.
* xsltproc (only if building from git)
* docbook-xsl (only if building from git)

To compile, run "make", but also see the file config.mk for more details on the
various options that can be compiled in.

Where possible use the Makefiles to compile. This is particularly relevant for
the client libraries as symbol information will be included.  Use cmake to
compile on Windows or Mac.

If you have any questions, problems or suggestions (particularly related to
installing on a more unusual device) then please get in touch using the details
in README.md.

# Compile to WASM using WASI-SDK and run with WAMR
For research purposes, mosquitto has been ported to WASM using WASI-SDK and WAMR. This guide aims to explain the necessary steps to come up with a basic and running version of Mosquitto. Note, that **not** all features are supported that native mosquitto supports.

## Prerequisites
Install WASI-SDK as well as WAMR-SDK as follows:
### WASI-SDK
Get a release of WASI-SDK from [here](https://github.com/WebAssembly/wasi-sdk/releases). For this guide, `wasi-sdk-20` has been used. Extract the archive to `/opt/wasi-sdk`.

### WAMR
Clone the repo of WAMR from [here](https://github.com/bytecodealliance/wasm-micro-runtime). At the time of writing, the commit `aaf671d` has been used.

Optimally, clone WAMR into `/opt/wasm-micro-runtime` in order to avoid extra configuration later.

#### Build WAMR
Build your own WAMR runtime according to the guides provided in the repo or [here](https://wamr.gitbook.io/document/). For this guide, the runtime has been built for `Linux`.

## Compile Mosquitto
Build mosquitto as follows:
```bash
#! Root of repo
# ensure everything is clean before starting
make clean
# build with make
# you can omit WAMR_PATH if it equals to /opt/wasm-micro-runtime
# you can omit WASI_SDK_PATH if it equals to /opt/wasi-sdk
make TARGET_WASM=yes WAMR_PATH=/path/to/WAMR/root WASI_SDK_PATH=/path/to/WASI-SDK/root 
```
You can add any other option to build mosquitto as described in the standard mosquitto documentation. However, note, that not all options are supported in WASI nor have been tested.

Currently, known options that are not supported or not tested are:
* `WITH_WRAP`
* `WITH_BRIDGE`
* `WITH_DB_UPGRADE`
* `WITH_SYSTEMD`
* `WITH_SRV`
* `WITH_WEBSOCKETS`
* `WITH_EC`
* `WITH_ADNS`
* `WITH_EPOLL` (no support in WASI)
* `WITH_UNIX_SOCKETS` (no support in WASI)
* `WITH_JEMALLOC` (must provide JEMALLOC WASI library)
* `WITH_CJSON`

Additionally, the following features are not supported / are not working
* Signal handling
* Plugin loading
* Build the shared library (shared library building is not yet supported by [WASI-SDK](https://github.com/WebAssembly/wasi-sdk#notable-limitations))

Experimental options
* `WITH_THREADING`: App compiles but might behave unexpected, e.g. tests are not able to compile and run

Known options, that are supported
* `WITH_TLS` (WITH WolfSSL only, see comment below)
* `WITH_TLS_PSK`
* `WITH_PERSISTENCE`
* `WITH_MEMORY_TRACKING`
* `WITH_SYS_TREE`
* `WITH_SOCKS` (client only)
* `WITH_CONTROL`

### TLS
WolfSSL has been used to provide TLS for mosquitto in the WASM version. WolfSSL works in general also for the Linux version of mosquitto. To enable WolfSSL (instead of the default OpenSSL), specify

``-DWITH_WOLFSSL=1``

#### Build WolfSSL
You will probably have to build first WolfSSL. To do so, perform the following steps:
1. Clone [WolfSSL](https://github.com/JamesMenetrey/wolfssl.git)
2. Build and install the linux version to have the header files installed
```bash
./autogen
./configure --enable-ocsp --enable-nginx --enable-opensslall --enable-stunnel

make
sudo make install
# update the linker cache
sudo ldconfig 
```

3. Build the wasm version of WolfSSL 
 * checkout the branch `wasm_merge_2023_03_31_with_ra`
 * go to ``IDE/Wasm`` and follow the instructions
4. Copy wolfssl lib
````bash
sudo cp libwolfssl.a build_deps/libwolfssl.a
````

Now you should be ready to build mosquitto with WolfSSL by running
````bash
# add your config to config.mk, then
make clean && make TARGET_WASM=yes
````

### Build for Linux SGX
Mosquitto broker is able to run in an [Intel SGX](https://www.intel.com/content/www/us/en/developer/tools/software-guard-extensions/overview.html) enclave with a few tradeoffs. Mosquitto will be running completely in the trusted part backed by [WAMR](https://github.com/bytecodealliance/wasm-micro-runtime). WAMR is able to load a WASM module into the trusted part and execute it completely isolated from the rest of the operating system. If you like to use TLS, you have to use WolfSSL (as described before, no more changes necessary). If you don't like to use TLS, then some adaptations in the code will be necessary as the broker currently expects certificates at compile time as well as at runtime.

The current tradeoffs are as follows:
* Certificates must be embedded at compile-time and are loaded from buffers instead of the filesystem
* Configuration must be embedded at compile-time and is loaded from a buffer
* ACL must be embedded at compile time
* Persistency is supported, but only on the untrusted file system (use of IFPS is not implemented)

Further, there are some features not working as expected compared to the native version, i.e.
* Domain Name Resolution is not available. Indicate the listener IP address instead of the host
* IPv6 addresses are not supported. You can just listen on IPv4 addresses
* Persistence: only supported without IFPS. The persisted file is readable to anyone!
* Differenct certificates per listener are not implemented, the borker uses the same embedded certificate for all listeners
* ACLs and CRLs are not implemented
* all features not working in WASM won't work here either

#### Compile
To get started, create in the root of this project a file called `mosquitto.conf` and put your configuration of the broker in it. 
Note about the non-working features described above

Next, create a folder in the root of this project called `certs` and place the following files in it with the correct name:
* `server.key`: the broker's private key
* `server.crt`: the server's certificate for the corresponding private key
* `ca.crt`: the certificate chain of all trusted certificates
* `psk_file.txt`: the file containing the pre-shared keys, can also be empty but must exist

If you have done these steps, you can run in the root of this project the following build command:
```bash
make TARGET_WASM=yes TARGET_INTEL_SGX=yes
```

Build the `wamrc` compiler as described [here](https://wamr.gitbook.io/document/basics/getting-started/build_wasm_app#compile-wasm-to-aot-module) and compile the wasm module outputted from the previous step using the following command
```bash
./wamrc -sgx -o src/mosquitto.aot src/mosquitto.wasm
```
#### Open Work
The mosquitto library used by clients has not been ported to Intel SGX. Additionally, all non working features as well as the tradeoffs listed above are subject to further development.

## Run with WAMR
Use your previously built WAMR runtime (in the following a file called `iwasm`) to run mosquitto as follows:
```bash
./iwasm --allow-resolve=<domains allowed to resolve> --addr-pool=<addr-pool to bind> src/mosquitto
```
To run it locally, you can for example run
```bash
# allow to resolve any domain and allow to bind IPv4 and IPv6 loopback addresses
./iwasm --allow-resolve=* --addr-pool=0.0.0.0/32,0000:0000:0000:0000:0000:0000:0000:0000/64 src/mosquitto
```
To run with config, you should first tell the wasm runtime that mosquitto has the right to access the config file and then tell mosquitto the location of the config file
```bash
./iwasm --allow-resolve=* --addr-pool=0.0.0.0/32,0000:0000:0000:0000:0000:0000:0000:0000/64 --dir=. src/mosquitto -c mosquitto.conf
```
Please note: As WASI `getaddrinfo` does not support to not specify the IP protocol version, a warning will be printed by mosquitto when you specify a listener in the config, and it will try to determine the IP protocol version by analyzing the address which usually succeeds.

## Run the client
The client can be run as well using the following commands:
### Subscribe
```bash
./iwasm --allow-resolve=* --addr-pool=0.0.0.0/32,0000:0000:0000:0000:0000:0000:0000:0000/64 client/mosquitto_sub -t 'test'
```
### Publish
```bash
./iwasm --allow-resolve=* --addr-pool=0.0.0.0/32,0000:0000:0000:0000:0000:0000:0000:0000/64 client/mosquitto_pub -t 'test' -m "Hello World"
```

## Run with SGX
To run mosquitto in an Intel SGX enclave, you need to build first the WAMR runtime for Intel SGX. To do so, build [WAMR](https://github.com/bytecodealliance/wasm-micro-runtime) in `product-mini/platforms/linux-sgx` as well as `product-mini/platforms/linux-sgx/enclave-sample` as described in the corresponding `README`. Use the `iwasm` from the `enclave-sample` build step to run the `mosquitto.aot` from your last build step. The commands to start the broker are the same except that you don't need to pass any configuration file and don't need to pass a list of allowed domains to resolve:
```bash
./iwasm --addr-pool=<addr-pool to bind> src/mosquitto.aot
```

If you like to use persistency and configured the app to do so, specify also the folder your application is allowed to access:
```bash
./iwasm --addr-pool=<addr-pool to bind> --dir=<list of directories> src/mosquitto.aot
```
However, be aware, that this places this file is unprotected and can be read by anyone having access to the system. This will likely break your trust chain!