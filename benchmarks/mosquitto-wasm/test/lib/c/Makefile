include ../../../config.mk

.PHONY: all clean reallyclean

CFLAGS=-I../../../include -Werror
# use static lib for WASM
ifeq ($(TARGET_WASM), yes)
LIBS=-I../../../lib -L../../../lib -lmosquitto $(WAMR_PATH)/core/iwasm/libraries/lib-socket/src/wasi/wasi_socket_ext.c -I$(WAMR_PATH)/core/iwasm/libraries/lib-socket/inc  -D_WASI_EMULATED_SIGNAL -Wl,-lwasi-emulated-signal
else
LIBS=../../../lib/libmosquitto.so.1
endif

SRC = \
	01-con-discon-success.c \
	01-keepalive-pingreq.c \
	01-no-clean-session.c \
	01-server-keepalive-pingreq.c \
	01-unpwd-set.c \
	01-will-set.c \
	01-will-unpwd-set.c \
	02-subscribe-qos0.c \
	02-subscribe-qos1.c \
	02-subscribe-qos2.c \
	02-unsubscribe-multiple-v5.c \
	02-unsubscribe-v5.c \
	02-unsubscribe.c \
	03-publish-b2c-qos1-unexpected-puback.c \
	03-publish-b2c-qos1.c \
	03-publish-b2c-qos2-len.c \
	03-publish-b2c-qos2-unexpected-pubrel.c \
	03-publish-b2c-qos2-unexpected-pubcomp.c \
	03-publish-b2c-qos2.c \
	03-publish-c2b-qos1-disconnect.c \
	03-publish-c2b-qos1-len.c \
	03-publish-c2b-qos1-receive-maximum.c \
	03-publish-c2b-qos2-disconnect.c \
	03-publish-c2b-qos2-len.c \
	03-publish-c2b-qos2-maximum-qos-0.c \
	03-publish-c2b-qos2-maximum-qos-1.c \
	03-publish-c2b-qos2-pubrec-error.c \
	03-publish-c2b-qos2-receive-maximum-1.c \
	03-publish-c2b-qos2-receive-maximum-2.c \
	03-publish-c2b-qos2.c \
	03-publish-qos0-no-payload.c \
	03-publish-qos0.c \
	03-request-response-1.c \
	03-request-response-2.c \
	03-request-response-correlation-1.c \
	04-retain-qos0.c \
	08-ssl-bad-cacert.c \
	08-ssl-connect-cert-auth-enc.c \
	08-ssl-connect-cert-auth.c \
	08-ssl-connect-no-auth.c \
	08-ssl-fake-cacert.c \
	09-util-topic-tokenise.c \
	11-prop-oversize-packet.c \
	11-prop-recv-qos0.c \
	11-prop-recv-qos1.c \
	11-prop-recv-qos2.c \
	11-prop-send-payload-format.c \
	11-prop-send-content-type.c

ifeq ($(WITH_TLS),yes)
SRC += \
	08-ssl-connect-cert-auth-custom-ssl-ctx.c \
	08-ssl-connect-cert-auth-custom-ssl-ctx-default.c
ifeq ($(WITH_WOLFSSL), yes)
LIBS += -lwolfssl -DWITH_WOLFSSL -L./../../../build_deps -I/usr/local/include
ifeq ($(TARGET_WASM), yes)
LIBS += -DWOLFSSL_WASM
endif
else
LIBS += -lssl -lcrypto
endif
endif

ifeq ($(WITH_THREADING),yes)
	SRC += \
		02-subscribe-qos1-async1.c \
		02-subscribe-qos1-async2.c
	ifeq ($(TARGET_WASM), yes)
		CFLAGS += --target=wasm32-wasi-threads
	endif
endif

TESTS = ${SRC:.c=.test}

all : ${TESTS}

${TESTS} : %.test: %.c
	${CROSS_COMPILE}$(CC) $< -o $@ $(CFLAGS) $(LIBS)

reallyclean : clean
	-rm -f *.orig

clean :
	rm -f *.test
