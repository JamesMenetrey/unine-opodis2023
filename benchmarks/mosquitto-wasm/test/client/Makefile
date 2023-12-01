.PHONY: all check test ptest clean

all :

check : test
ptest : test
test :
ifeq ($(TARGET_WASM),yes)
	./test_wasi.sh
else
	./test.sh
endif

clean:
