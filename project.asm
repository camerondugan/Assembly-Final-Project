%include 'print.asm'
%include 'read.asm'
%include 'convert.asm'

section .bss
buffer  resb 1000

section .data
var1    equ 5
var2    equ 4
var3    equ 3
arr     dd 0, 0, 0

section .txt
global  _start

_start:
	;    maxStack
	push var3
	push var2
	push var1
	call maxStack

	mov  ebx, buffer
	call int2str
	mov  eax, buffer
	call printLF

	;    maxNoStack
	push var3
	push var2
	push var1
	call maxNoStack

	mov  ebx, buffer
	call int2str
	mov  eax, buffer
	call printLF

	;    fill
	push 3
	push arr
	call maxStack

	mov  ebx, buffer
	call int2str
	mov  eax, buffer
	call printLF

	;    fillReverse
	push 3
	push arr
	call fillReverse

	mov  ebx, buffer
	call int2str
	mov  eax, buffer
	call printLF

	mov ebx, 0; exit
	mov eax, 1
	int 0x80

.err:
	mov ebx, 1; error
	mov eax, 1
	int 0x80

fill:
	mov eax, [esp+4]
	add eax, [esp+8]
	ret

fillReverse:
	ret

maxNoStack:
	ret

maxStack:
	ret
