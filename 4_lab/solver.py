import sys
import numpy as np

def solve():
    fname = sys.argv[1]
    d = open(fname).readlines()
    n = int(d[0])
    m1 = d[1:n+1]
    m1 = [[float(u) for u in k.strip().split()] for k in m1]
    rn = d[n+1:]
    rn = [[float(u) for u in k.strip().split()] for k in rn]
    A = np.asarray(m1)
    B = np.asarray(rn)
    print(A)
    print("=======")
    print(B)
    print("=======")
    print("A**2")
    A2 = np.matmul(A, A)
    print(A2)
    print("B**2")
    B2 = np.matmul(B, B)
    print(B2)
    print("A+B")
    AplusB = np.add(A, B)
    print(AplusB)
    print("A-B")
    AminB  = np.subtract(A, B)
    print(AminB)
    print("(A+B)*(A-B)")
    LargeProduct = np.matmul(AplusB, AminB)
    print(LargeProduct)
    print("A^2-B^2")
    left = np.subtract(A2, B2)
    print(left)
    print("result")
    res = np.subtract(left, LargeProduct)
    print(res)

if __name__ == "__main__":
    solve()


