CFLAGS = -O3
LDFLAGS = -lmosquitto -lwolfssl
INCLUDES = -I/usr/local/include
COMPILE_FLAGS = -DWITH_TLS
HOST_NAME = "\"172.28.1.59\""

all: subscriber_scaling message_rate_scaling publisher_scaling subscriber

subscriber_scaling : subscriber_scaling.o subscriber.o publisher.o tracker.o
	$(CROSS_COMPILE)$(CC) $^ -o $@ $(LDFLAGS)

message_rate_scaling : message_rate_scaling.o subscriber.o publisher.o tracker.o
	$(CROSS_COMPILE)$(CC) $^ -o $@ $(LDFLAGS)

publisher_scaling : publisher_scaling.o subscriber.o publisher.o tracker.o
	$(CROSS_COMPILE)$(CC) $^ -o $@ $(LDFLAGS)

publisher : publisher.c tracker.o
	$(CROSS_COMPILE)$(CC) $(CFLAGS) $(COMPILE_FLAGS) -DSTANDALONE -DHOST_NAME=$(HOST_NAME) $^ -o $@ $(LDFLAGS)

subscriber_standalone : subscriber.c tracker.o
	$(CROSS_COMPILE)$(CC) $(CFLAGS) $(COMPILE_FLAGS) -DSTANDALONE -DHOST_NAME=$(HOST_NAME) $^ -o $@ $(LDFLAGS)

subscriber: subscriber.c tracker.o
	$(CROSS_COMPILE)$(CC) $(CFLAGS) -DSTANDALONE -DHOST_NAME=$(HOST_NAME) $^ -o $@ $(LDFLAGS)

subscriber_scaling.o: case_2.c
	$(CROSS_COMPILE)$(CC) $(CFLAGS) $(COMPILE_FLAGS) -DSUBSCRIBER_SCALE -c $< -o $@

message_rate_scaling.o: case_2.c
	$(CROSS_COMPILE)$(CC) $(CFLAGS) $(COMPILE_FLAGS) -DMESSAGE_RATE_SCALE -c $< -o $@

publisher_scaling.o: case_2.c
	$(CROSS_COMPILE)$(CC) $(CFLAGS) $(COMPILE_FLAGS) -DPUBLISHER_SCALE -c $< -o $@

tracker.o: tracker.c
	$(CROSS_COMPILE)$(CC) $(CFLAGS) $(COMPILE_FLAGS) -c $< -o $@

subscriber.o: subscriber.c
	$(CROSS_COMPILE)$(CC) $(CFLAGS) -DHOST_NAME=$(HOST_NAME) $(COMPILE_FLAGS) -c $< -o $@

publisher.o: publisher.c
	$(CROSS_COMPILE)$(CC) $(CFLAGS) -DHOST_NAME=$(HOST_NAME) $(COMPILE_FLAGS) -c $< -o $@

clean:
	rm -f subscriber_scaling message_rate_scaling publisher_scaling publisher subscriber subscriber_standalone *.o