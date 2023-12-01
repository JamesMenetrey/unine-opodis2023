include ../config.mk

DIRS= \
		db_dump \
		mosquitto_ctrl

ifneq ($(TARGET_WASM), yes)
	DIRS+= mosquitto_passwd
endif

.PHONY : all binary check clean reallyclean test install uninstall

all :
	set -e; for d in ${DIRS}; do $(MAKE) -C $${d}; done
binary :
	set -e; for d in ${DIRS}; do $(MAKE) -C $${d} $@; done

clean :
	set -e; for d in ${DIRS}; do $(MAKE) -C $${d} $@; done

reallyclean :
	set -e; for d in ${DIRS}; do $(MAKE) -C $${d} $@; done

check : test
test :
	set -e; for d in ${DIRS}; do $(MAKE) -C $${d} $@; done

install :
	set -e; for d in ${DIRS}; do $(MAKE) -C $${d} $@; done

uninstall :
	set -e; for d in ${DIRS}; do $(MAKE) -C $${d} $@; done
