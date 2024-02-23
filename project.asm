%include 'print.asm'
%include 'read.asm'
%include 'convert.asm'
%include 'utils.asm'

section .bss
buffer  resb 1000
n       resd 1; num elements in S (calculated at runtime)

	section .data
	S       dd 7, 3, 5, 12, 2, 1, 5, 3, 8, 4, 6, 4
	Sbytes  equ ($-S)
	Ssize   equ 4

	k    equ 5
	;    messages
	msg1 db "k-partition of set S not possible", 0

	section .txt
	global  _start

_start:
	;find n
	mov   [n], dword 12
	mov   eax, [n]
	mov   ebx, buffer
	call  int2str
	mov   eax, buffer
	call  printLF

	; mov eax, S
	; mov ebx, k
	; mov ecx, n
	; call partition

	push S
	push k
	call sum

	mov ebx, 0; exit
	mov eax, 1
	int 0x80

error:
	mov ebx, 1; error
	mov eax, 1
	int 0x80

	; Method with params and stack frame
	; eax=S, ebx=k, ecx=n

partition:
	mov edx, n
	cmp edx, k
	jge .continue

	mov  eax, msg1; subset too small for k partitions
	call printLF
	jmp  error

.continue:
	ret
