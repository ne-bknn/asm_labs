import os
import sys

try:
    test = sys.argv[1]
except KeyError:
    print("python run.py <test>")
    sys.exit()

os.system(f"qemu-aarch64 -L /usr/aarch64-linux-gnu ./4_lab.out {test}")
