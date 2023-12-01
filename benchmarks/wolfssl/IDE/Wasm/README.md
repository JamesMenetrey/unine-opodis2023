# Building WolfSSL for use in WebAssembly applications
Bringing WebAssembly (Wasm) support for WolfSSL with *WebAssembly system interface* (WASI) support for seamless interoperability with the underlying system.

### Requirements
It is expected that the [WASI-SDK](https://github.com/WebAssembly/wasi-sdk) is installed at the path `/opt/wasi-sdk`, or given via the variable `WASI_SDK_PATH`.

WolfSSL environment must have been configured using `./autogen.sh`.

### Build
The project creates the static library `libwolfssl.a`, ready to be linked with Wasm applications that rely on WolfSSL as a dependency.

To compile the static library, call make:

`make -f wasm_static.mk all`

To clean the static library and compiled objects use the provided clean script:

`make -f wasm_static.mk clean`

### Usage
Wasm applications can link the static library. An example is given in the WolfSSL Examples GitHub repository.

### Customization
- To enable debugging output, specify: `DEBUG` at build

### Limitations
- Single Threaded (multiple threaded applications have not been tested)
- AES-NI use with SGX has not been added in yet
