# Tests

## Running

The Mosquitto test suite can be invoked using either of

```
make test
make check
```

The tests run in series and due to the nature of some of the tests being made
can take a while.

## Parallel Tests

To run the tests with some parallelism, use

```
make ptest
```

This runs up to 20 tests in parallel at once, yielding much faster overall run
time at the expense of having up to 20 instances of Python running at once.
This is not a particularly CPU intensive option, but does require more memory
and may be unsuitable on e.g. a Raspberry Pi.

## Dependencies

The tests require Python 3 and CUnit to be installed.

# Run tests WASM
There are various adaptations of the test suite to run with WASM. Currently, Unit Tests cannot be compiled as the `CUnit` library depends on `setjmp` which is not supported by WASI. 

Regarding the other tests, you can set the flag `wasm` in `test/mosq_test.py` to `True` to run tests with a WASM broker. Note, that this assumes that you have a `WAMR` runtime called `iwasm` in the root of this repository.

Then, run the tests using
```bash
make TARGET_WASM=yes test
```

## Current state of the tests in WASM
* broker: Tests pass except those testing signal handling and SSL tests with CRLs
* client: Tests pass except for input from stdin due to threading issue
* lib: Tests are working (if compiled without THREADING), but static lib is used instead of shared lib
* unit: Tests are not working due to missing working version of CUnit in WASM (missing setjmp support)

Note: To run ssl related tests, move the generated ssl certificates into the folder you are currently testing. E.g. when running tests from `broker` folder, then move / copy the `ssl` folder into the `broker` folder. 

Additionally, you need an excecutable [WAMR runtime](https://github.com/bytecodealliance/wasm-micro-runtime) called `iwasm` in the root of the mosquitto repository. See more information in `README-compiling`.

# Run tests IntelSGX
The IntelSGX implementation depends on the WASM implementation and therefore has the same limitations.

In a standard SGX use case one would not pass the configuration using a file that resides in the untrusted part. However, to simplify testing, we should still rely on a configuration file as otherwise for every new test configuration a rebuild would be necessary. Consequently, do not build mosquitto with `-SGX_EMBEDDED_CONFIG=yes`.

Additionally, a special flag intended for testing called `SGX_TEST_MODE` has been introduced that automatically sets the `socket_domain` on the listener to `Ipv4` to avoid rewrite all configuration.

This means, you should build the broker like the following:

````bash
make TARGET_WASM=yes TARGET_INTEL_SGX=yes SGX_TEST_MODE=yes
````

Further, you will have to set the flag `wasm` in `test/mosq_test.py` to `False` and the flag `wasm_sgx` to `True`.
Additionally, you will need to setup a WAMR runtime and an enclave. Please follow the details in the `README-compiling.md` to setup.

Eventually, you can run the tests
````bash
make TARGET_WASM=yes TARGET_INTEL_SGX=yes test
````

Note, that only broker tests are working as the clients have not been ported to Intel SGX.