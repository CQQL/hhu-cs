%include "asm_io.inc"

segment .data
  codebase dd 0deadbeefh
  erg      db "Ergebnis : ",0
segment .bss
segment .text
  global asm_main
asm_main:
  ; Register sichern
  enter 0,0
  pusha

  ; Werte in Register laden
  mov eax, [codebase]
  mov ecx, 32 ; 32 Durchläufe
  mov ebx, 0

  ; Beginn der Schleife
start:
  ; Alle Bits in eax um 1 nach links verschieben (dabei geht das höchste Bit in CF)
  shl eax, 1

  ; Wenn das höchste Bit eine 1 war, ebx erhöhen
  jnc continue
  inc ebx
continue:
  loop start ; ecx dekrementieren und zu start springen, wenn ecx != 0

  ; Ergebnis in ebx ausgeben
  mov eax, erg
  call print_string
  mov eax, ebx
  call print_int
  call print_nl

  ; Register wiederherstellen und 0 zurückgeben
  popa
  mov eax, 0
  leave
  ret
