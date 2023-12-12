# A Holistic Approach for Trustworthy Distributed Systems with WebAssembly and TEEs

DOI: 10.4230/LIPIcs.OPODIS.2023.23 (submission in progress)

Read the paper on: [arXiv](https://arxiv.org/abs/2312.00702)

The paper version is published in the proceedings of the 27th Conference on Principles of Distributed Systems (OPODIS'23), Tokyo, Japan, December 2023.  
Website of the conference: [OPODIS'23](https://xdefago.github.io/opodis23/)


## Structure of the repository
The benchmarks and instructions to reproduce the experiments are available in the directory [benchmarks](benchmarks/).  
The fork of the [Mosquitto](benchmarks/mosquitto-wasm/) is based on the revision [4e6fbae4](https://github.com/eclipse/mosquitto/tree/4e6fbae4).  
The fork of [WolfSSL](benchmarks/wolfssl/) is based on the revision [2ad0659f](https://github.com/wolfSSL/wolfssl/tree/2ad0659f).

## Licenses
- Mosquitto is dual licensed under the [Eclipse Public License 2.0](https://github.com/eclipse/mosquitto/blob/4e6fbae45ce424d2204c8b5d51b37dc5a08013bc/epl-v20) and the [Eclipse Distribution License 1.0](https://github.com/eclipse/mosquitto/blob/4e6fbae45ce424d2204c8b5d51b37dc5a08013bc/edl-v10).
- The changes of this paper are also written under this license.
WolfSSL is licensed under the [GNU General Public License v2.0](https://github.com/wolfSSL/wolfssl/blob/master/COPYING).
- The changes of this paper are also written under this license.
The benchmark scripts and analysis files are licensed under [the Apache License 2.0](LICENSE.md).


## Code attributions
- WolfSSL patches for the compilation in WebAssembly have been written by Jämes Ménétrey, University of Neuchâtel, Switzerland.
- WolfSSL patches for the attestation extension have been written by Julius Oeftiger, University of Bern, Switzerland.
- Mosquitto patches for the compilation in WebAssembly and integration with WolfSSL have been written by Aeneas Grüter, University of Bern, Switzerland.

## Authors of the work
The authors of the scientific contributions are:

- Jämes Ménétrey, University of Neuchâtel, Switzerland
- Aeneas Grüter, University of Bern, Switzerland
- Peterson Yuhala, University of Neuchâtel, Switzerland
- Julius Oeftiger, University of Bern, Switzerland
- Pascal Felber, University of Neuchâtel, Switzerland
- Marcelo Pasin, University of Neuchâtel, Switzerland
- Valerio Schiavoni, University of Neuchâtel, Switzerland
