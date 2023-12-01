include ../common.mk

Wolfssl_C_Extra_Flags += -DHAVE_KEYING_MATERIAL -DHAVE_REMOTE_ATTESTATION
Wolfssl_C_Extra_Flags += -DWOLFSSL_ECH=yes -DWOLFSSL_HPKE=yes -DWOLFSSL_SNI=yes

.PHONY: all
all:
	clang \
		-c \
		-fPIC \
		$(Wolfssl_C_Extra_Flags) \
		$(Wolfssl_Include_Paths) \
		$(Wolfssl_C_Files)
	clang \
		-shared \
		-lm \
		-o libwolfssl.so \
		*.o

.PHONY: clean
clean:
	rm *.o *.so