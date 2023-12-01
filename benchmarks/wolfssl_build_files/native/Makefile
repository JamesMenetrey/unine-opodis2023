include ../common.mk

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