#!/bin/bash
set -o pipefail
qemu-aarch64 -L /usr/aarch64-linux-gnu main $1 $2 $3
feh $1 $2 $3
