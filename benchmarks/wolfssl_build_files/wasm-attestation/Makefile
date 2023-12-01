include ../common.mk

WASI_SDK_PATH ?= /opt/wasi-sdk


Wolfssl_C_Extra_Flags += -DWOLFSSL_WASM
Wolfssl_C_Extra_Flags += -DHAVE_KEYING_MATERIAL -DHAVE_REMOTE_ATTESTATION
Wolfssl_C_Extra_Flags += -DWOLFSSL_ECH=yes -DWOLFSSL_HPKE=yes -DWOLFSSL_SNI=yes

.PHONY: all
all:
	# Preprocess, compile and assemble WolfSSL in Wasm
	$(WASI_SDK_PATH)/bin/clang \
		-c \
		--target=wasm32-wasi \
		--sysroot=$(WASI_SDK_PATH)/share/wasi-sysroot/ \
		$(Wolfssl_C_Extra_Flags) \
		$(Wolfssl_Include_Paths) \
		$(Wolfssl_C_Files)

	# Archive all the assembled files to create a static library in Wasm
	$(WASI_SDK_PATH)/bin/llvm-ar rcs libwolfssl.a *.o

.PHONY: clean
clean:
	rm *.o *.a
