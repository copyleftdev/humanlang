CC = gcc
CFLAGS = -Wall -Wextra -std=c11 -O2
LDFLAGS = -lpthread

TARGET = rate_limiter
SRC = rate_limiter.c

all: $(TARGET)

$(TARGET): $(SRC)
	$(CC) $(CFLAGS) -o $@ $< $(LDFLAGS)

clean:
	rm -f $(TARGET)

run: $(TARGET)
	./$(TARGET)

.PHONY: all clean run
