; Ich nehme an, dass 1 Datenwort 1 Byte ist.
; Dann hat der Cache 4 Zeilen mit jeweils 2 Blöcken von jeweils 2 Worten.
; Die Adressen sind dann unterteilt in 1 Word-Bit, 2 Line-Bits und der Rest ist Tag.

segment .data
  input_format db "%d", 0
  output_format db "Line: %d, Tag: %d", 0Ah, 0
segment .text
  global asm_main
  extern scanf
  extern printf
asm_main:
  enter 0, 0
  pusha

  push DWORD 0
  push esp
  push input_format
  call scanf
  add esp, 8

  mov eax, [esp]
  shr eax, 3
  push eax
  mov eax, [esp + 4]
  and eax, 110b
  shr eax, 1
  push eax
  push output_format
  call printf
  add esp, 16
  
  popa
  leave
  mov eax, 0
  ret
