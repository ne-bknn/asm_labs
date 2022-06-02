#include <unistd.h>
#include <stdio.h>
#include <fcntl.h>

int main(int argc, char** argv) {
  int fd = openat(-100, argv[1], 0);
  printf("%d\n", fd);
  char b[100];
  b[99] = 0;
  read(3, b, 99);
  printf("%s\n", b);
}
