CC := gcc
CXX := g++

CFLAGS := -Wall -O2 -DWFB_VERSION='"23.10.28.62752-3fb19b3a"'
LDFLAGS := -lrt -lpcap -lsodium

SOURCES := src/rx.c src/tx.c src/keygen.c src/radiotap.c src/fec.c src/wifibroadcast.c
OBJECTS := $(SOURCES:.c=.o)
EXECUTABLES := wfb_rx wfb_tx wfb_keygen

all: $(EXECUTABLES)

%.o: %.c
	$(CC) $(CFLAGS) -std=gnu99 -c -o $@ $<

%.o: %.cpp
	$(CXX) $(CFLAGS) -std=gnu++11 -c -o $@ $<

wfb_rx: src/rx.o src/radiotap.o src/fec.o src/wifibroadcast.o
	$(CXX) -o $@ $^ $(LDFLAGS)

wfb_tx: src/tx.o src/fec.o src/wifibroadcast.o
	$(CXX) -o $@ $^ $(LDFLAGS)

wfb_keygen: src/keygen.o
	$(CC) -o $@ $^ $(LDFLAGS)

clean:
	rm -f $(EXECUTABLES) $(OBJECTS)

.PHONY: all clean
