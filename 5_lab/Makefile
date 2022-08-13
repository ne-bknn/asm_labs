CC       := aarch64-linux-gnu-gcc
AS       := aarch64-linux-gnu-as
LD       := aarch64-linux-gnu-ld
CUR_PATH := $(shell pwd)
BASENAME := $(shell basename $(CUR_PATH))

.PHONY: default
default: build

SRCS = $(wildcard *.s)

PROGS = $(patsubst %.s,%,$(SRCS))

.PHONY: all 
all: $(PROGS)

func.o: func2.s
	$(AS) -g -o $@ $^

main.o: main.c
	$(CC)  -g -c main.c -o main.o

main: main.o func.o
	$(CC) -L /usr/aarch64-linux-gnu/ -lc -lm -g -ggdb $^ -o $@

.PHONY: build
build: main

.PHONY: run
run: main
	qemu-aarch64 -L /usr/aarch64-linux-gnu main pic.png pic_out.png

.PHONY: clean
clean:
	-rm *.out *.o &> /dev/null || true

.PHONY: debug
debug: main
	$(eval TMP := $(shell mktemp /tmp/gdb-config.XXXXXX))
	echo -e "set architecture aarch64\nfile main\ntarget remote localhost:31337" > $(TMP)
	tmux new-session -d 'qemu-aarch64 -L /usr/aarch64-linux-gnu -g 31337 main small.png pic_out_1.png pic_out_2.png; $$SHELL'
	tmux split-window -h 'gdb-multiarch -x $(TMP)'
	tmux select-pane -t 0
	tmux split-window -v -p 75 'vim main.c'
	-tmux -2 attach-session -d
	-rm $(TMP) && pkill qemu && sleep 0.1 && pkill -9 qemu
	-rm *.core
