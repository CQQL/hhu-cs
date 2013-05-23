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

  push DWORD 0

  ; Load number into esp
  push esp
  push input_format
  call scanf
  add esp, 8

  call fib
  add esp, 4

  push eax
  push output_format
  call printf
  add esp, 8

  popa
  mov eax, 0
  leave
  ret

; Compute the n-th fibonacci number
fib:
  enter 0, 0
  push ebx

  cmp [ebp + 8], DWORD 0
  je n_is_zero

  cmp [ebp + 8], DWORD 1
  je n_is_one

  ; Compute fib(n - 1) and save it in ebp
  mov eax, [ebp + 8]
  sub eax, 1
  push eax
  call fib
  add esp, 4
  mov ebx, eax

  ; Compute fib(n - 2)
  mov eax, [ebp + 8]
  sub eax, 2
  push eax
  call fib
  add esp, 4
  
  ; Add the results 
  add eax, ebx

  jmp return

n_is_zero:
  mov eax, 0
  jmp return

n_is_one:
  mov eax, 1
  jmp return

return:
  pop ebx
  leave
  ret
