import subprocess
import os
import random
from string import ascii_lowercase
import numpy as np
import math

def np_matrix_to_str(A):
    A_list = A.tolist()
    A_str = "\n".join([" ".join([str(k) for k in g]) for g in A_list])
    return A_str

def solve(A, B):
    A2 = np.matmul(A, A)
    B2 = np.matmul(B, B)
    AplusB = np.add(A, B)
    AminB  = np.subtract(A, B)
    LargeProduct = np.matmul(AplusB, AminB)
    left = np.subtract(A2, B2)
    res = np.subtract(left, LargeProduct)
    return np_matrix_to_str(res)

def random_matrix():
    n = random.randrange(1, 21)
    A = np.random.rand(n, n)*10
    B = np.random.rand(n, n)*10
    A_str = np_matrix_to_str(A)
    B_str = np_matrix_to_str(B)

    solution = solve(A, B)

    f_contents = f"{n}\n{A_str}\n{B_str}"
    return f_contents, solution
    
def run_test(i):
    fcontents, ans = random_matrix()
    fname = "tmp"+str(random.randrange(0,1000)).zfill(4)+".in"
    f = open(fname, "w")
    f.write(fcontents)
    f.close()

    res = subprocess.check_output(["qemu-aarch64", "-L", "/usr/aarch64-linux-gnu", "./4_lab.out", fname]).decode()
    res = [float(k) for k in res.split()]
    ans = [float(k) for k in ans.split()]
    
    if not all(math.isclose(a, b, abs_tol=0.000001) for a, b in zip(res, ans)):
        print("INPUT")
        print(fcontents.encode())
        print("===")
        print("BINARY")
        print(res)
        print("===")
        print("PYTHON")
        print(ans)
        input()
    else:
        print(f"ok {str(i).zfill(7)}", end="\r")

    os.unlink(fname)

if __name__ == "__main__":
    i = 0
    while True:
        run_test(i)
        i += 1

