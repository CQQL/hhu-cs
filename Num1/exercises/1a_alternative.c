#include <stdio.h>

/*
 * Printf IEEE double machine epsilon.
 */
int main () {
  double d = 5.0;
  int* p = (int*)&d;
  p[0] = 0x00000001;
  p[1] = 0x3FF00000;

  printf("%e %08X%08X\n", d - 1.0, p[1], p[0]);

  return 0;
}
