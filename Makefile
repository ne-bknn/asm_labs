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

%: %.s 
	$(AS) -g -o $@.o $<
	$(LD) -s -static -L /usr/aarch64-linux-gnu/ -lc -g -o $@.out $@.o 
	rm *.o


.PHONY: build
build: main.s
	$(AS) -g -o $(BASENAME).o $^
	$(LD) -L /usr/aarch64-linux-gnu/ -lc -g -o $(BASENAME).out $(BASENAME).o 
	-@rm $(BASENAME).o

.PHONY: abuild
abuild: main.s 
	$(CC) -g -L /usr/aarch64-linux-gnu -lc -g -o $(BASENAME).out main.s

.PHONY: run
run: $(BASENAME).out
	qemu-aarch64 -L /usr/aarch64-linux-gnu $(BASENAME).out t11

.PHONY: clean
clean:
	-rm *.out *.o &> /dev/null || true

.PHONY: debug
debug: $(BASENAME).out
	$(eval TMP := $(shell mktemp /tmp/gdb-config.XXXXXX))
	echo -e "set architecture aarch64\nfile $(BASENAME).out\ntarget remote localhost:31337" > $(TMP)
	tmux new-session -d 'qemu-aarch64 -L /usr/aarch64-linux-gnu -g 31337 $(BASENAME).out t5; $$SHELL'
	tmux split-window -h 'gdb-multiarch -x $(TMP)'
	tmux select-pane -t 0
	tmux split-window -v -p 75 'vim main.s'
	-tmux -2 attach-session -d
	-rm $(TMP) && pkill qemu && sleep 0.1 && pkill -9 qemu
	-rm *.core
