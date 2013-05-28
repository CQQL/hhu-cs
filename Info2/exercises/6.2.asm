segment .data
  input_format db "%d", 0
  output_format db "%d", 0Ah, 0

segment .text
  global asm_main
  extern scanf
  extern printf

asm_main:
  enter 0, 0
  pusha
  mov ebp, esp

  ; Lokale Variable anlegen
  push DWORD 0

  ; n in die lokale Variable einlesen
  push esp
  push input_format
  call scanf
  add esp, 8

  ; Die lokale Variable liegt jetzt oben auf dem Stack und kann so an fib übergeben werden
  call fib
  add esp, 4

  ; fib(n) ausgeben
  push eax
  push output_format
  call printf
  add esp, 8

  popa
  mov eax, 0
  leave
  ret

; Berechnung von fib(n)
fib:
  enter 0, 0
  push ebx

  ; fib(0) = 0
  cmp [ebp + 8], DWORD 0
  je n_is_zero

  ; fib(1) = 1
  cmp [ebp + 8], DWORD 1
  je n_is_one

  ; fib(n - 1) berechnen und in ebx speichern
  mov eax, [ebp + 8]
  sub eax, 1
  push eax
  call fib
  add esp, 4
  mov ebx, eax

  ; fib(n - 2) berechnen
  mov eax, [ebp + 8]
  sub eax, 2
  push eax
  call fib
  add esp, 4
  
  ; fib(n) = fib(n - 1) + fib(n - 2)
  add eax, ebx

  jmp return

; 0 zurückgeben
n_is_zero:
  mov eax, 0
  jmp return

; 1 zurückgeben
n_is_one:
  mov eax, 1
  jmp return

; Funktion verlassen
return:
  pop ebx
  leave
  ret
