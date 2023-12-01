# =============================================================================
# User configuration section.
#
# These options control compilation on all systems apart from Windows and Mac
# OS X. Use CMake to compile on Windows and Mac.
#
# Largely, these are options that are designed to make mosquitto run more
# easily in restrictive environments by removing features.
#
# Modify the variable below to enable/disable features.
#
# Can also be overriden at the command line, e.g.:
#
# make WITH_TLS=no
# =============================================================================

# Uncomment to compile the broker with tcpd/libwrap support.
#WITH_WRAP:=yes

# Comment in if you like to compile to WASM. 
# Please note about supported features if using WASM
# by reading the README-compiling file.
#TARGET_WASM=yes

# Comment out to disable SSL/TLS support in the broker and client.
# Disabling this will also mean that passwords must be stored in plain text. It
# is strongly recommended that you only disable WITH_TLS if you are not using
# password authentication at all.
WITH_TLS:=yes

# Comment in to use WolfSSL instead of OpenSSL for the broker and the client.
# Note that if you compile to WASM, only WolfSSL is supported.
WITH_WOLFSSL:=yes

# This requires a version of wolfssl that supports remote attestation
# It creates two new callbacks on the client library to support remote attestation
WITH_ATTESTATION:=no

# This feature requires INTEL SGX and enables on the broker side remote attestation
# it requires the same version of wolfssl as WITH_ATTESTATION does
# and depends on LIBRATS to generate the attestation
WITH_BROKER_ATTESTATION:=no

# Comment out to disable TLS/PSK support in the broker and client. Requires
# WITH_TLS=yes.
# This must be disabled if using openssl < 1.0.
WITH_TLS_PSK:=yes

# Compile with SGX support
# this imposes some limits on the broker
# but enables to run mosquitto in an SGX enclave
# read more in the README-compiling.md
#TARGET_INTEL_SGX?=yes

# If you want to use the embedded config for Intel SGX, set this to yes
# otherwise, the broker will parse the config from the file system
# if you use protected file system, you will need to write the config for the broker to read it
# if you don't use protected file system, this will be a security issue
# This flag is ignored if TARGET_INTEL_SGX=no
#SGX_EMBEDDED_CONFIG?=yes

# Test mode for SGX automatically sets the domain to IPv4 and prevents a rewrite of the tests
# Only intended for testing
# This flag is ignored if TARGET_INTEL_SGX=no
#SGX_TEST_MODE?=yes

# Comment out to disable client threading support.
WITH_THREADING:=no

# Comment out to remove bridge support from the broker. This allow the broker
# to connect to other brokers and subscribe/publish to topics. You probably
# want to leave this included unless you want to save a very small amount of
# memory size and CPU time.
WITH_BRIDGE:=no

# Comment out to remove persistent database support from the broker. This
# allows the broker to store retained messages and durable subscriptions to a
# file periodically and on shutdown. This is usually desirable (and is
# suggested by the MQTT spec), but it can be disabled if required.
WITH_PERSISTENCE:=yes

# Comment out to remove memory tracking support from the broker. If disabled,
# mosquitto won't track heap memory usage nor export '$SYS/broker/heap/current
# size', but will use slightly less memory and CPU time.
WITH_MEMORY_TRACKING:=yes

# Compile with database upgrading support? If disabled, mosquitto won't
# automatically upgrade old database versions.
# Not currently supported.
#WITH_DB_UPGRADE:=yes

# Comment out to remove publishing of the $SYS topic hierarchy containing
# information about the broker state.
WITH_SYS_TREE:=yes

# Build with systemd support. If enabled, mosquitto will notify systemd after
# initialization. See README in service/systemd/ for more information.
# Setting to yes means the libsystemd-dev or similar package will need to be
# installed.
WITH_SYSTEMD:=no

# Build with SRV lookup support.
WITH_SRV:=no

# Build with websockets support on the broker.
WITH_WEBSOCKETS:=no

# Use elliptic keys in broker
WITH_EC:=no

# Build man page documentation by default.
WITH_DOCS:=no

# Build with client support for SOCK5 proxy.
WITH_SOCKS:=yes

# Strip executables and shared libraries on install.
WITH_STRIP:=no

# Build static libraries
WITH_STATIC_LIBRARIES:=yes

# Use this variable to add extra library dependencies when building the clients
# with the static libmosquitto library. This may be required on some systems
# where e.g. -lz or -latomic are needed for openssl.
CLIENT_STATIC_LDADD:=

# Build shared libraries
WITH_SHARED_LIBRARIES:=yes

# Build with async dns lookup support for bridges (temporary). Requires glibc.
#WITH_ADNS:=yes

# Build with epoll support.
WITH_EPOLL:=no

# Build with bundled uthash.h
WITH_BUNDLED_DEPS:=yes

# Build with coverage options
WITH_COVERAGE:=no

# Build with unix domain socket support
WITH_UNIX_SOCKETS:=no

# Build mosquitto_sub with cJSON support
WITH_CJSON:=no

# Build mosquitto with support for the $CONTROL topics.
WITH_CONTROL:=yes

# Build the broker with the jemalloc allocator
WITH_JEMALLOC:=no

# Build with xtreport capability. This is for debugging purposes and is
# probably of no particular interest to end users.
WITH_XTREPORT=no

# =============================================================================
# End of user configuration
# =============================================================================


# Also bump lib/mosquitto.h, CMakeLists.txt,
# installer/mosquitto.nsi, installer/mosquitto64.nsi
VERSION=2.0.15

# Client library SO version. Bump if incompatible API/ABI changes are made.
SOVERSION=1

# Man page generation requires xsltproc and docbook-xsl
XSLTPROC=xsltproc --nonet
# For html generation
DB_HTML_XSL=man/html.xsl

#MANCOUNTRIES=en_GB

UNAME:=$(shell uname -s)
ARCH:=$(shell uname -p)

CFLAGS=-O3

ifeq ($(UNAME),SunOS)
	ifeq ($(CC),cc)
		CFLAGS?=-O
	else
		CFLAGS?=-Wall -ggdb -O2
	endif
else
	CFLAGS?=-Wall -ggdb -O2 -Wconversion -Wextra
endif

ifeq ($(TARGET_WASM), yes)
	WAMR_PATH ?= /opt/wasm-micro-runtime
	WASI_SDK_PATH?= /opt/wasi-sdk
	CROSS_COMPILE = $(WASI_SDK_PATH)/bin/
	CC = clang
	INCS += -I$(WAMR_PATH)/core/iwasm/libraries/lib-socket/inc
	LDFLAGS:=${LDFLAGS}
	ifeq ($(WITH_TLS), yes)
		INCS:=${INCS} -I/usr/local/include
		CFLAGS:= ${CFLAGS} -DWOLFSSL_WASM -DWITH_WOLFSSL
		LDFLAGS:= ${LDFLAGS} -L./../build_deps
	endif

	CFLAGS:=${CFLAGS} -Wno-sign-conversion -D_WASI_EMULATED_GETPID ${INCS}
	ifeq ($(WITH_THREADING), yes)
		CFLAGS:=${CFLAGS} --target=wasm32-wasi-threads -pthread
		LDFLAGS:=${LDFLAGS} -lpthread -Wl,--initial-memory=196608 -Wl,--export=__main_argc_argv -Wl,--export=__heap_base -Wl,--export=__data_end
	endif

    LDFLAGS:=${LDFLAGS} -Wl,-lwasi-emulated-getpid -Wl,--allow-undefined-file=$(WASI_SDK_PATH)/share/wasi-sysroot/share/wasm32-wasi-threads/defined-symbols.txt --sysroot=$(WASI_SDK_PATH)/share/wasi-sysroot/ ${INCS}
endif


STATIC_LIB_DEPS:=

APP_CPPFLAGS=$(CPPFLAGS) -I. -I../../ -I../../include -I../../src -I../../lib
APP_CFLAGS=$(CFLAGS) -DVERSION=\""${VERSION}\""
APP_LDFLAGS:=$(LDFLAGS)

LIB_CPPFLAGS=$(CPPFLAGS) -I. -I.. -I../include -I../../include
LIB_CFLAGS:=$(CFLAGS)
LIB_CXXFLAGS:=$(CXXFLAGS)
LIB_LDFLAGS:=$(LDFLAGS)
LIB_LIBADD:=$(LIBADD)

BROKER_CPPFLAGS:=$(LIB_CPPFLAGS) -I../lib
BROKER_CFLAGS:=${CFLAGS} -DVERSION="\"${VERSION}\"" -DWITH_BROKER
BROKER_LDFLAGS:=${LDFLAGS}
BROKER_LDADD:=

CLIENT_CPPFLAGS:=$(CPPFLAGS) -I.. -I../include
CLIENT_CFLAGS:=${CFLAGS} -DVERSION="\"${VERSION}\""
CLIENT_LDFLAGS:=$(LDFLAGS) -L../lib
CLIENT_LDADD:=

PASSWD_LDADD:=

PLUGIN_CPPFLAGS:=$(CPPFLAGS) -I../.. -I../../include
PLUGIN_CFLAGS:=$(CFLAGS) -fPIC
PLUGIN_LDFLAGS:=$(LDFLAGS)

ifeq ($(TARGET_WASM), yes)
	PLUGIN_LDFLAGS:=$(PLUGIN_LDFLAGS) -Wl,--no-entry -Wl,--export-all -Wl,--allow-undefined
	BROKER_LDFLAGS:=$(BROKER_LDFLAGS) $(WAMR_PATH)/core/iwasm/libraries/lib-socket/src/wasi/wasi_socket_ext.c
	CLIENT_LDFLAGS:=$(CLIENT_LDFLAGS) $(WAMR_PATH)/core/iwasm/libraries/lib-socket/src/wasi/wasi_socket_ext.c
endif

ifneq ($(or $(findstring $(UNAME),FreeBSD), $(findstring $(UNAME),OpenBSD), $(findstring $(UNAME),NetBSD)),)
	BROKER_LDADD:=$(BROKER_LDADD) -lm
	ifneq ($(TARGET_WASM), yes)
		BROKER_LDFLAGS:=$(BROKER_LDFLAGS) -Wl,--dynamic-list=linker.syms
	endif
	SEDINPLACE:=-i ""
else
	BROKER_LDADD:=$(BROKER_LDADD) -ldl -lm
	SEDINPLACE:=-i
endif

ifeq ($(UNAME),Linux)
	BROKER_LDADD:=$(BROKER_LDADD) -lrt
	ifneq ($(TARGET_WASM), yes)
		BROKER_LDFLAGS:=$(BROKER_LDFLAGS) -Wl,--dynamic-list=linker.syms
	endif
	LIB_LIBADD:=$(LIB_LIBADD) -lrt
endif

ifeq ($(WITH_SHARED_LIBRARIES),yes)
	CLIENT_LDADD:=${CLIENT_LDADD} ../lib/libmosquitto.so.${SOVERSION}
endif

ifeq ($(UNAME),SunOS)
	SEDINPLACE:=
	ifeq ($(ARCH),sparc)
		ifeq ($(CC),cc)
			LIB_CFLAGS:=$(LIB_CFLAGS) -xc99 -KPIC
		else
			LIB_CFLAGS:=$(LIB_CFLAGS) -fPIC
		endif
	endif
	ifeq ($(ARCH),i386)
		LIB_CFLAGS:=$(LIB_CFLAGS) -fPIC
	endif

	ifeq ($(CXX),CC)
		LIB_CXXFLAGS:=$(LIB_CXXFLAGS) -KPIC
	else
		LIB_CXXFLAGS:=$(LIB_CXXFLAGS) -fPIC
	endif
else
	LIB_CFLAGS:=$(LIB_CFLAGS) -fPIC
	LIB_CXXFLAGS:=$(LIB_CXXFLAGS) -fPIC
endif

ifneq ($(UNAME),SunOS)
	ifneq ($(TARGET_WASM), yes)
		LIB_LDFLAGS:=$(LIB_LDFLAGS) -Wl,--version-script=linker.version -Wl,-soname,libmosquitto.so.$(SOVERSION)
	endif
endif

ifeq ($(UNAME),QNX)
	BROKER_LDADD:=$(BROKER_LDADD) -lsocket
	LIB_LIBADD:=$(LIB_LIBADD) -lsocket
endif

ifeq ($(WITH_WRAP),yes)
	BROKER_LDADD:=$(BROKER_LDADD) -lwrap
	BROKER_CPPFLAGS:=$(BROKER_CPPFLAGS) -DWITH_WRAP
endif

ifeq ($(WITH_TLS),yes)
	APP_CPPFLAGS:=$(APP_CPPFLAGS) -DWITH_TLS
	BROKER_CPPFLAGS:=$(BROKER_CPPFLAGS) -DWITH_TLS
	CLIENT_CPPFLAGS:=$(CLIENT_CPPFLAGS) -DWITH_TLS
	LIB_CPPFLAGS:=$(LIB_CPPFLAGS) -DWITH_TLS
	ifeq ($(WITH_WOLFSSL),yes)
		BROKER_LDADD:=$(BROKER_LDADD) -lwolfssl -DWITH_WOLFSSL
		CLIENT_CPPFLAGS:=$(CLIENT_CPPFLAGS) -DWITH_TLS -DWITH_WOLFSSL
		LIB_LIBADD:=$(LIB_LIBADD) -lwolfssl -DWITH_WOLFSSL
		PASSWD_LDADD:=$(PASSWD_LDADD) -lwolfssl -DWITH_WOLFSSL
		STATIC_LIB_DEPS:=$(STATIC_LIB_DEPS) -lwolfssl -DWITH_WOLFSSL
		APP_CPPFLAGS:=$(APP_CPPFLAGS) -DWITH_WOLFSSL
		BROKER_CPPFLAGS:=$(BROKER_CPPFLAGS) -DWITH_WOLFSSL
		CLIENT_CPPFLAGS:=$(CLIENT_CPPFLAGS) -DWITH_WOLFSSL
		LIB_CPPFLAGS:=$(LIB_CPPFLAGS) -DWITH_WOLFSSL
		ifeq ($(WITH_ATTESTATION),yes)
			ifeq ($(WITH_BROKER_ATTESTATION),yes)
				BROKER_CFLAGS:=${BROKER_CFLAGS} -I${WAMR_PATH}/core/iwasm/libraries/lib-rats
				BROKER_LDFLAGS:=${BROKER_LDFLAGS} -Wl,--allow-undefined
				BROKER_CPPFLAGS:=$(BROKER_CPPFLAGS) -DWITH_BROKER_ATTESTATION
			endif
			LIB_CPPFLAGS:=$(LIB_CPPFLAGS) -DWITH_ATTESTATION
			LIB_CFLAGS:=$(LIB_CFLAGS) -DWITH_ATTESTATION
			LIB_LDFLAGS:=$(LIB_LDFLAGS)
		endif
	else
		ifeq ($(TARGET_WASM), yes)
			ERROR_MSG:="OpenSSL is not available in WASM. Please use WolfSSL instead."
		endif
		ifeq ($(WITH_ATTESTATION),yes)
			ERROR_MSG:="Remote attestation is only available with WolfSSL."
		endif
		BROKER_LDADD:=$(BROKER_LDADD) -lssl -lcrypto
		LIB_LIBADD:=$(LIB_LIBADD) -lssl -lcrypto
		PASSWD_LDADD:=$(PASSWD_LDADD) -lcrypto
		STATIC_LIB_DEPS:=$(STATIC_LIB_DEPS) -lssl -lcrypto
	endif

	ifeq ($(WITH_TLS_PSK),yes)
		BROKER_CPPFLAGS:=$(BROKER_CPPFLAGS) -DWITH_TLS_PSK
		LIB_CPPFLAGS:=$(LIB_CPPFLAGS) -DWITH_TLS_PSK
		CLIENT_CPPFLAGS:=$(CLIENT_CPPFLAGS) -DWITH_TLS_PSK
	endif
endif

ifeq ($(TARGET_INTEL_SGX),yes)
	BROKER_CFLAGS:=$(BROKER_CFLAGS) -DINTEL_SGX
	LIB_CFLAGS:=$(LIB_CFLAGS) -DINTEL_SGX

	ifeq ($(SGX_EMBEDDED_CONFIG),yes)
		BROKER_CFLAGS:=$(BROKER_CFLAGS) -DSGX_EMBEDDED_CONFIG
	endif
	ifeq ($(SGX_TEST_MODE),yes) 
		BROKER_CFLAGS:=$(BROKER_CFLAGS) -DSGX_TEST_MODE
	endif
endif

ifeq ($(WITH_THREADING),yes)
	ifneq ($(TARGET_WASM), yes)
		LIB_LDFLAGS:=$(LIB_LDFLAGS) -pthread
		STATIC_LIB_DEPS:=$(STATIC_LIB_DEPS) -pthread
	endif
	LIB_CPPFLAGS:=$(LIB_CPPFLAGS) -DWITH_THREADING
	CLIENT_CPPFLAGS:=$(CLIENT_CPPFLAGS) -DWITH_THREADING
endif

ifeq ($(WITH_SOCKS),yes)
	LIB_CPPFLAGS:=$(LIB_CPPFLAGS) -DWITH_SOCKS
	CLIENT_CPPFLAGS:=$(CLIENT_CPPFLAGS) -DWITH_SOCKS
endif

ifeq ($(WITH_BRIDGE),yes)
	BROKER_CPPFLAGS:=$(BROKER_CPPFLAGS) -DWITH_BRIDGE
endif

ifeq ($(WITH_PERSISTENCE),yes)
	BROKER_CPPFLAGS:=$(BROKER_CPPFLAGS) -DWITH_PERSISTENCE
endif

ifeq ($(WITH_MEMORY_TRACKING),yes)
	ifneq ($(UNAME),SunOS)
		BROKER_CPPFLAGS:=$(BROKER_CPPFLAGS) -DWITH_MEMORY_TRACKING
	endif
endif

ifeq ($(WITH_SYS_TREE),yes)
	BROKER_CPPFLAGS:=$(BROKER_CPPFLAGS) -DWITH_SYS_TREE
endif

ifeq ($(WITH_SYSTEMD),yes)
	BROKER_CPPFLAGS:=$(BROKER_CPPFLAGS) -DWITH_SYSTEMD
	BROKER_LDADD:=$(BROKER_LDADD) -lsystemd
endif

ifeq ($(WITH_SRV),yes)
	LIB_CPPFLAGS:=$(LIB_CPPFLAGS) -DWITH_SRV
	LIB_LIBADD:=$(LIB_LIBADD) -lcares
	CLIENT_CPPFLAGS:=$(CLIENT_CPPFLAGS) -DWITH_SRV
	STATIC_LIB_DEPS:=$(STATIC_LIB_DEPS) -lcares
endif

ifeq ($(UNAME),SunOS)
	BROKER_LDADD:=$(BROKER_LDADD) -lsocket -lnsl
	LIB_LIBADD:=$(LIB_LIBADD) -lsocket -lnsl
endif

ifeq ($(WITH_EC),yes)
	BROKER_CPPFLAGS:=$(BROKER_CPPFLAGS) -DWITH_EC
endif

ifeq ($(WITH_ADNS),yes)
	BROKER_LDADD:=$(BROKER_LDADD) -lanl
	BROKER_CPPFLAGS:=$(BROKER_CPPFLAGS) -DWITH_ADNS
endif

ifeq ($(WITH_CONTROL),yes)
	BROKER_CPPFLAGS:=$(BROKER_CPPFLAGS) -DWITH_CONTROL
endif

MAKE_ALL:=mosquitto
ifeq ($(WITH_DOCS),yes)
	MAKE_ALL:=$(MAKE_ALL) docs
endif

ifeq ($(WITH_JEMALLOC),yes)
	BROKER_LDADD:=$(BROKER_LDADD) -ljemalloc
endif

ifeq ($(WITH_UNIX_SOCKETS),yes)
	BROKER_CPPFLAGS:=$(BROKER_CPPFLAGS) -DWITH_UNIX_SOCKETS
	LIB_CPPFLAGS:=$(LIB_CPPFLAGS) -DWITH_UNIX_SOCKETS
	CLIENT_CPPFLAGS:=$(CLIENT_CPPFLAGS) -DWITH_UNIX_SOCKETS
endif

ifeq ($(WITH_WEBSOCKETS),yes)
	BROKER_CPPFLAGS:=$(BROKER_CPPFLAGS) -DWITH_WEBSOCKETS
	BROKER_LDADD:=$(BROKER_LDADD) -lwebsockets
endif

INSTALL?=install
prefix?=/usr/local
incdir?=${prefix}/include
libdir?=${prefix}/lib${LIB_SUFFIX}
localedir?=${prefix}/share/locale
mandir?=${prefix}/share/man
STRIP?=strip

ifeq ($(WITH_STRIP),yes)
	STRIP_OPTS?=-s --strip-program=${CROSS_COMPILE}${STRIP}
endif

ifeq ($(WITH_EPOLL),yes)
	ifeq ($(UNAME),Linux)
		BROKER_CPPFLAGS:=$(BROKER_CPPFLAGS) -DWITH_EPOLL
	endif
endif

ifeq ($(WITH_BUNDLED_DEPS),yes)
	BROKER_CPPFLAGS:=$(BROKER_CPPFLAGS) -I../deps
	LIB_CPPFLAGS:=$(LIB_CPPFLAGS) -I../deps
	PLUGIN_CPPFLAGS:=$(PLUGIN_CPPFLAGS) -I../../deps
endif

ifeq ($(WITH_COVERAGE),yes)
	BROKER_CFLAGS:=$(BROKER_CFLAGS) -coverage
	BROKER_LDFLAGS:=$(BROKER_LDFLAGS) -coverage
	PLUGIN_CFLAGS:=$(PLUGIN_CFLAGS) -coverage
	PLUGIN_LDFLAGS:=$(PLUGIN_LDFLAGS) -coverage
	LIB_CFLAGS:=$(LIB_CFLAGS) -coverage
	LIB_LDFLAGS:=$(LIB_LDFLAGS) -coverage
	CLIENT_CFLAGS:=$(CLIENT_CFLAGS) -coverage
	CLIENT_LDFLAGS:=$(CLIENT_LDFLAGS) -coverage
endif

ifeq ($(WITH_CJSON),yes)
	CLIENT_CFLAGS:=$(CLIENT_CFLAGS) -DWITH_CJSON
	CLIENT_LDADD:=$(CLIENT_LDADD) -lcjson
	CLIENT_STATIC_LDADD:=$(CLIENT_STATIC_LDADD) -lcjson
	CLIENT_LDFLAGS:=$(CLIENT_LDFLAGS)
endif

ifeq ($(WITH_XTREPORT),yes)
	BROKER_CFLAGS:=$(BROKER_CFLAGS) -DWITH_XTREPORT
endif

BROKER_LDADD:=${BROKER_LDADD} ${LDADD}
CLIENT_LDADD:=${CLIENT_LDADD} ${LDADD}
PASSWD_LDADD:=${PASSWD_LDADD} ${LDADD}
