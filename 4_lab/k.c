#include <stdio.h>
#include <string.h>
#include <unistd.h>

int main(int argc, char** argv) {
  FILE* f = fopen(argv[1], "r");
  if (f == 0) {
    printf("Failed to open file %s.\n", argv[1]);
    return 1;
  }
  printf("here");
  char buf[1000];
  memset(buf, 0, sizeof(buf));
  size_t s = fread(buf, 1, 999, f);
  printf("%d", s);
  printf("%s", buf);
  return 0;
}
