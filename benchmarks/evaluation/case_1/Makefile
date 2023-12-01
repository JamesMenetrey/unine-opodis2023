CFLAGS = -O3
LDFLAGS = -lmosquitto -lwolfssl
INCLUDES = -I/usr/local/include -I../case_2
COMPILE_FLAGS = -DWITH_TLS #-DWITH_ATTESTATION -DHAVE_REMOTE_ATTESTATION #-DWITH_PSK 
HOST_NAME = "\"172.28.1.59\""

all: case_1

case_1 : case_1.o connect_client.o tracker.o
	$(CROSS_COMPILE)$(CC) $^ -o $@ $(LDFLAGS)

connect_client : connect_client.c
	$(CROSS_COMPILE)$(CC) $(CFLAGS) $(COMPILE_FLAGS) $(INCLUDES) -DHOST_NAME=$(HOST_NAME) -DSTANDALONE $^ -o $@ $(LDFLAGS)

connect_client.o: connect_client.c
	$(CROSS_COMPILE)$(CC) $(CFLAGS) $(COMPILE_FLAGS) $(INCLUDES) -DHOST_NAME=$(HOST_NAME) -c $< -o $@

case_1.o: case_1.c
	$(CROSS_COMPILE)$(CC) $(CFLAGS) $(COMPILE_FLAGS) -c $< -o $@

tracker.o: ../case_2/tracker.c
	$(CROSS_COMPILE)$(CC) $(CFLAGS) $(COMPILE_FLAGS) -c ../case_2/$< -o $@

clean:
	rm -f case_1 connect_client *.o