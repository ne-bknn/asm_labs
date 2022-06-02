#include <stdio.h>
#include <unistd.h>

int main() {
  char b[21];
  while (scanf(" %20[^ |\t\n] ", b) > 0) {
    printf("%s", b);
  }
}
