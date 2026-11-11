#include "stdio.h"

// TODO:
// BUG:
// NOTE:
// FIX:
// HACK:

void print(const char *name, int value) {
  printf("%s = %d\n", name, value);
}

int main(void) {
  int cnt = 13;
  const char *test = "cnt";
  print(test, cnt);
  return 0;
}
