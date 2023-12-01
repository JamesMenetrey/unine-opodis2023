WOLFSSL_ROOT ?= $(shell readlink -f ../../wolfssl)
WASI_SDK_PATH = /opt/wasi-sdk
Wolfssl_C_Extra_Flags = -O3
Wolfssl_C_Extra_Flags +=	-DGENERATE_MACHINE_PARSEABLE_REPORT
Wolfssl_C_Extra_Flags +=	-DWOLFSSL_AES_DIRECT -DHAVE_AES_KEYWRAP -DHAVE_CAMELLIA -DWOLFSSL_SHA224 -DWOLFSSL_SHA512 -DWOLFSSL_SHA384 -DHAVE_HKDF -DTFM_ECC256 -DECC_SHAMIR \
	 						-DWC_RSA_PSS -DWOLFSSL_DH_EXTRA -DWOLFSSL_BASE64_ENCODE -DWOLFSSL_SHA3 -DHAVE_POLY1305 -DHAVE_ONE_TIME_AUTH \
							-DHAVE_CHACHA -DHAVE_HASHDRBG -DHAVE_OPENSSL_CMD -DHAVE_CRL -DHAVE_TLS_EXTENSIONS -DHAVE_SUPPORTED_CURVES \
							-DHAVE_FFDHE_2048 -DHAVE_SUPPORTED_CURVES -DFP_MAX_BITS=8192 -DWOLFSSL_ALT_CERT_CHAINS \
							-DWOLFSSL_TLS13 -DWOLFSSL_POST_HANDSHAKE_AUTH -DWOLFSSL_SEND_HRR_COOKIE -DWOLFSSL_HKDF -DWC_RSA_PSS -DWOLFSSL_AESGCM -DWOLFSSL_ECC -DWOLFSSL_CURVE25519 -DWOLFSSL_ED25519 \
							-DWOLFSSL_CURVE448 -DWOLFSSL_ED448

Wolfssl_C_Extra_Flags +=	-DTFM_TIMING_RESISTANT -DECC_TIMING_RESISTANT -DWC_RSA_BLINDING -DHAVE_AESGCM -DGCM_TABLE_4BIT -DHAVE_AESCCM -DHAVE_ECC -DNO_MAIN_DRIVER -DHAVE_SYS_TIME_H
Wolfssl_C_Extra_Flags +=	-DSINGLE_THREADED -DUSE_CERT_BUFFERS_2048 -DUSE_FAST_MATH
Wolfssl_C_Extra_Flags +=	-DTFM_NO_ASM -DWOLFSSL_NO_ASM

# Flags for OpenSSL compatibility
Wolfssl_C_Extra_Flags +=  	-DHAVE_OCSP -DHAVE_CERTIFICATE_STATUS_REQUEST -DOPENSSL_EXTRA -DOPENSSL_ALL -DHAVE_EX_DATA -DSESSION_CERTS -DWOLFSSL_SYS_CA_CERTS -DOPENSSL_COMPATIBLE_DEFAULTS -DGCM_TABLE_4BIT


Wolfssl_C_Files :=$(WOLFSSL_ROOT)/wolfcrypt/src/aes.c\
					$(WOLFSSL_ROOT)/wolfcrypt/src/arc4.c\
					$(WOLFSSL_ROOT)/wolfcrypt/src/asn.c\
					$(WOLFSSL_ROOT)/wolfcrypt/src/blake2b.c\
					$(WOLFSSL_ROOT)/wolfcrypt/src/camellia.c\
					$(WOLFSSL_ROOT)/wolfcrypt/src/coding.c\
					$(WOLFSSL_ROOT)/wolfcrypt/src/chacha.c\
					$(WOLFSSL_ROOT)/wolfcrypt/src/chacha20_poly1305.c\
					$(WOLFSSL_ROOT)/src/crl.c\
					$(WOLFSSL_ROOT)/wolfcrypt/src/des3.c\
					$(WOLFSSL_ROOT)/wolfcrypt/src/dh.c\
					$(WOLFSSL_ROOT)/wolfcrypt/src/tfm.c\
					$(WOLFSSL_ROOT)/wolfcrypt/src/ecc.c\
					$(WOLFSSL_ROOT)/wolfcrypt/src/error.c\
					$(WOLFSSL_ROOT)/wolfcrypt/src/hash.c\
					$(WOLFSSL_ROOT)/wolfcrypt/src/kdf.c\
					$(WOLFSSL_ROOT)/wolfcrypt/src/hmac.c\
					$(WOLFSSL_ROOT)/wolfcrypt/src/integer.c\
					$(WOLFSSL_ROOT)/src/internal.c\
					$(WOLFSSL_ROOT)/src/wolfio.c\
					$(WOLFSSL_ROOT)/src/keys.c\
					$(WOLFSSL_ROOT)/wolfcrypt/src/logging.c\
					$(WOLFSSL_ROOT)/wolfcrypt/src/md4.c\
					$(WOLFSSL_ROOT)/wolfcrypt/src/md5.c\
					$(WOLFSSL_ROOT)/wolfcrypt/src/memory.c\
					$(WOLFSSL_ROOT)/src/ocsp.c\
					$(WOLFSSL_ROOT)/wolfcrypt/src/pkcs7.c\
					$(WOLFSSL_ROOT)/wolfcrypt/src/pkcs12.c\
					$(WOLFSSL_ROOT)/wolfcrypt/src/poly1305.c\
					$(WOLFSSL_ROOT)/wolfcrypt/src/wc_port.c\
					$(WOLFSSL_ROOT)/wolfcrypt/src/wolfmath.c\
					$(WOLFSSL_ROOT)/wolfcrypt/src/pwdbased.c\
					$(WOLFSSL_ROOT)/wolfcrypt/src/random.c\
					$(WOLFSSL_ROOT)/wolfcrypt/src/ripemd.c\
					$(WOLFSSL_ROOT)/wolfcrypt/src/rsa.c\
					$(WOLFSSL_ROOT)/wolfcrypt/src/dsa.c\
					$(WOLFSSL_ROOT)/wolfcrypt/src/sha.c\
					$(WOLFSSL_ROOT)/wolfcrypt/src/sha3.c\
					$(WOLFSSL_ROOT)/wolfcrypt/src/sha256.c\
					$(WOLFSSL_ROOT)/wolfcrypt/src/sha512.c\
					$(WOLFSSL_ROOT)/wolfcrypt/src/signature.c\
					$(WOLFSSL_ROOT)/wolfcrypt/src/sp_c32.c\
					$(WOLFSSL_ROOT)/wolfcrypt/src/sp_c64.c\
					$(WOLFSSL_ROOT)/src/ssl.c\
					$(WOLFSSL_ROOT)/src/tls.c\
					$(WOLFSSL_ROOT)/src/tls13.c\
					$(WOLFSSL_ROOT)/wolfcrypt/src/wc_encrypt.c\
					$(WOLFSSL_ROOT)/wolfcrypt/src/wolfevent.c\

Wolfssl_Include_Paths := -I$(WOLFSSL_ROOT)/ \
						 -I$(WOLFSSL_ROOT)/wolfcrypt/