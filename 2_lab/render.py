#!/usr/bin/python3

from jinja2 import Environment, FileSystemLoader
from random import randrange

env = Environment(loader=FileSystemLoader('.'))
template = env.get_template("main.tpl")

n_rows = randrange(3,6)
n_columns = randrange(3,6)
random_matrix = [[randrange(-10, +10) for _ in range(n_columns)] for _ in range(n_rows)]
str_matrix = [", ".join([str(c) for c in e]) for e in random_matrix]
sums = [sum(e) for e in random_matrix]
res = zip(str_matrix, sums)

output = template.render(n_rows=n_rows, n_columns=n_columns, numbers=res)

with open("main.s", "w") as f:
    f.write(output)
