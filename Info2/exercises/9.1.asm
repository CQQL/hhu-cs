segment .text
  global asm_main
asm_main:
  xor eax, ebx
  xor ebx, eax
  xor eax, ebx

  ret
