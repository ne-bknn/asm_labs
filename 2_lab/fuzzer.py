#!/usr/bin/python3

from jinja2 import Environment, FileSystemLoader
from random import randrange
import tempfile
import subprocess
import os

def render_source(random_matrix):
    env = Environment(loader=FileSystemLoader('.'))
    template = env.get_template("main.tpl")

    n_rows = len(random_matrix)
    n_columns = len(random_matrix[0])
    indecies = ", ".join([str(n) for n in range(0, n_rows)])
    sums_t = ", ".join([str(k) for k in [0,]*n_rows])
    str_matrix = [", ".join([str(c) for c in e]) for e in random_matrix]
    sums = [sum(e) for e in random_matrix]
    res = zip(str_matrix, sums)

    output = template.render(n_rows=n_rows, n_columns=n_columns, numbers=res, indecies=indecies, sums=sums_t)
    return output

def compile(source: str):
    def _compile(path: str):
        cmd1 = ["aarch64-linux-gnu-as", "-g", "-o", path+".o", path] 
        cmd2 = ["aarch64-linux-gnu-ld", "-L", "/usr/aarch64-linux-gnu/", "-lc", "-g", "-o", path+".out", path+".o"]
        proc = subprocess.run(cmd1)
        if proc.returncode != 0:
            raise Exception("Assembler failed")
        proc = subprocess.run(cmd2)
        if proc.returncode != 0:
            raise Exception("Linking failed")

    f = open("src"+str(randrange(1000, 9999))+".s", "w")
    try:
        f.write(source)
        f.close()
        _compile(f.name) 
    finally:
        f.close()
        os.unlink(f.name+".o")

    return f.name+".out"

def generate_matrix():
    n_rows = randrange(2, 20)
    n_cols = randrange(2, 20)
    random_matrix = [[randrange(-10, +10) for _ in range(n_cols)] for _ in range(n_rows)]

    return random_matrix

def get_answer(matrix):
    from operator import itemgetter
    sums = [sum(k) for k in matrix]
    matrix = sorted(zip(matrix, sums), key=itemgetter(1))
    sorted_matrix = [k[0] for k in matrix]
    return " ".join([" ".join([str(l) for l in k]) for k in sorted_matrix])

def run_binary(binary):
    proc = subprocess.run(["qemu-aarch64", "-L", "/usr/aarch64-linux-gnu", binary], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    stdout = proc.stdout.decode("utf-8")
    return stdout

def main():
    matrix = generate_matrix()
    answer = get_answer(matrix)
    source = render_source(matrix)
    binary = compile(source)
    binary_answer = run_binary(binary)
    print(answer)
    print(binary_answer)


if __name__ == "__main__":
    main()
