segment .date
  a_prompt db "a: ", 0
  b_prompt db "b: ", 0
  output_format db "euclid: %d", 0ah, 0
  number_scan db "%d", 0
segment .text
  global asm_main
  extern scanf
  extern printf
asm_main:
  enter 0, 0
  pusha

  ; a in ecx lesen
  push a_prompt
  call read_number
  add esp, 4
  mov ecx, eax

  ; b in ebx lesen
  push b_prompt
  call read_number
  add esp, 4
  mov ebx, eax

  ; euclid(a, b) berechnen
  push ebx
  push ecx
  call euclid
  add esp, 8

  ; Ergebnis ausgeben
  push eax
  push output_format
  call printf
  add esp, 8

  popa
  mov eax, 0
  leave
  ret

; Liest eine Zahl von der Konsole ein. Als Argument wird das prompt übergeben
read_number:
  push ebp
  mov ebp, esp
  push ecx ; printf verändert ecx ohne es zu speichern

  ; Eingabeprompt ausgeben
  push DWORD [ebp + 8]
  call printf
  add esp, 4

  ; Lokale Variable anlegen
  push DWORD 0

  ; Zahl in lokale Variable einlesen
  push esp
  push number_scan
  call scanf
  add esp, 8

  ; Wert in der lokalen Variable als Rückgabewert setzen
  mov eax, [esp]

  ; Lokale Variable freigeben
  add esp, 4

  pop ecx
  pop ebp
  ret

; ggT(a, b)
euclid:
  push ebp
  mov ebp, esp
  push ebx
  push edx

  ; a in eax laden
  mov eax, [ebp + 8]

  ; b in ebx laden
  mov ebx, [ebp + 12]

loop:
  ; a zurückgeben, wenn b 0 ist
  cmp ebx, 0
  je return

  ; edx muss auf 0 gesetzt werden, damit div funktioniert
  xor edx, edx

  div ebx      ; r = a mod b
  mov eax, ebx ; a = b
  mov ebx, edx ; b = r

  jmp loop

return:
  pop edx
  pop ebx
  mov esp, ebp
  pop ebp
  ret
