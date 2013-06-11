segment .data
  input_format db "%d", 0
  output_format db "%d", 0Ah, 0
  a_prompt db "a: ", 0
  b_prompt db "b: ", 0
  c_prompt db "c: ", 0
  d_prompt db "d: ", 0
  e_prompt db "e: ", 0
segment .text
  global asm_main
  extern printf
  extern scanf
asm_main:
  push ebp
  push ebx
  mov ebp, esp

  ; lokale Variablen a-e anlegen
  sub esp, 20

  ; a einlesen
  push a_prompt
  call printf
  add esp, 4
  lea eax, [ebp]
  push eax
  push input_format
  call scanf
  add esp, 8

  ; b einlesen
  push b_prompt
  call printf
  add esp, 4
  lea eax, [ebp - 4]
  push eax
  push input_format
  call scanf
  add esp, 8

  ; c einlesen
  push c_prompt
  call printf
  add esp, 4
  lea eax, [ebp - 8]
  push eax
  push input_format
  call scanf
  add esp, 8

  ; d einlesen
  push d_prompt
  call printf
  add esp, 4
  lea eax, [ebp - 12]
  push eax
  push input_format
  call scanf
  add esp, 8

  ; e einlesen
  push e_prompt
  call printf
  add esp, 4
  lea eax, [ebp - 16]
  push eax
  push input_format
  call scanf
  add esp, 8

  ; Wert berechnen
  ; eax = bd
  mov eax, [ebp - 4]
  and eax, [ebp - 12]

  ; ebx = not a
  mov ebx, [ebp]
  xor ebx, 0FFFFFFFFh

  ; eax = not a + bd
  or eax, ebx

  ; eax = (not a + bd)c
  and eax, [ebp - 8]

  ; c negieren
  mov ebx, [ebp - 8]
  xor ebx, 0FFFFFFFFh
  mov [ebp - 8], ebx

  ; e negieren
  mov ebx, [ebp - 16]
  xor ebx, 0FFFFFFFFh
  mov [ebp - 16], ebx

  ; ebx = a(not c)(not e)
  mov ebx, [ebp]
  and ebx, [ebp - 8]
  and ebx, [ebp - 16]

  ; eax = (not a + bd)c + a(not c)(not e)
  or eax, ebx

  ; nur das erste Bit betrachten
  and eax, 01h

  ; Ergebnis ausgeben
  push eax
  push output_format
  call printf
  add esp, 8
  
  ; lokale Variablen freigeben
  add esp, 20

  pop ebx
  pop ebp
  mov eax, 0
  ret
