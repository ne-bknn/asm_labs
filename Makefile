CC       := aarch64-linux-gnu-as
LD       := aarch64-linux-gnu-ld
CUR_PATH := $(shell pwd)
BASENAME := $(shell basename $(CUR_PATH))

.PHONY: default
default: build

.PHONY: build
build: *.s
	$(CC) -g -o $(BASENAME).o $^
	$(LD) -s -static -g -o $(BASENAME).out $(BASENAME).o 

.PHONY: abuild # alternative building, use it when using libc functions
abuild: *.s
	aarch64-linux-gnu-gcc -g -static -o $(BASENAME).out $^

.PHONY: run
run: $(BASENAME).out
	qemu-aarch64 $(BASENAME).out

.PHONY: clean
clean:
	-rm *.out *.o &> /dev/null || true

.PHONY: debug
debug: $(BASENAME).out
	$(eval TMP := $(shell mktemp /tmp/gdb-config.XXXXXX))
	echo -e "set architecture aarch64\nfile $(BASENAME).out\ntarget remote localhost:31337" > $(TMP)
	tmux new-session -d 'qemu-aarch64 -g 31337 $(BASENAME).out && $$SHELL'
	tmux split-window -h 'gdb-multiarch -x $(TMP)'
	-tmux -2 attach-session -d
	-rm $(TMP) && pkill -9 qemu
