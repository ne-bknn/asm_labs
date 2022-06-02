import subprocess
import os
import random
from string import ascii_lowercase

def random_text():
    text = []
    for i in range(random.randrange(100,1000)):
        if random.random() < 0.2:
            text.append(" ")
            if random.random() < 0.1:
                text.append(" ")
        elif random.random() < 0.1:
            text.append("\n")
        else:
            text.append(random.choice(ascii_lowercase))
    
    return "".join(text)

def answer(text: str):
    lines = text.split("\n")
    s1 = []
    for line in lines:
        s2 = []
        for w in line.split():
            s2.append(w)
            if len(w) % 2 == 0:
                s2.append(w)
        if len(s2) != 0:
            s1.append(" ".join(s2))

    return "\n".join(s1)

def run_test(i):
    text = random_text()
    fname = "tmp"+str(random.randrange(0,1000)).zfill(4)+".in"
    f = open(fname, "w")
    f.write(text)
    f.close()

    res = subprocess.check_output(["qemu-aarch64", "-L", "/usr/aarch64-linux-gnu", "./3_lab.out", fname]).decode()
    os.unlink(fname)
    ans = answer(text)
    if (res != ans):
        print("INPUT")
        print(text.encode())
        print("===")
        print("BINARY")
        print(res.encode())
        print("===")
        print("PYTHON")
        print(ans.encode())
        input()
    else:
        print(f"ok {str(i).zfill(7)}", end="\r")

if __name__ == "__main__":
    i = 0
    while True:
        run_test(i)
        i += 1

