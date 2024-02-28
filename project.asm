%include 'print.asm'
%include 'read.asm'
%include 'convert.asm'
%include 'utils.asm'

	section .data
	S       dd 7, 3, 5, 12, 2, 1, 5, 3, 8, 4, 6, 4
	;       S       dd 3, 1, 5, 3
	Sbytes  equ ($-S)
	Ssize   equ 4

	k          equ 5
	;          messages
	msg1       db "k-partition of set S not possible", 0
	sumLeft    dd k; for partition all 0's
	lenSumLeft equ ($-sumLeft)

	section .bss
	buffer  resb 1000
	n       resd 1; num elements in S (calculated at runtime)

	section .txt
	global  _start

_start:
	;   find n
	mov edx, 0
	mov eax, Sbytes
	mov ebx, Ssize
	div ebx
	
	mov [n], eax

	; ; print eax
	; mov  ebx, buffer
	; call int2str
	; mov  eax, buffer
	; call printLF

	mov  eax, S
	mov  ebx, k
	mov  ecx, [n]
	call partition

	mov ebx, 0; exit
	mov eax, 1
	int 0x80

error:
	mov ebx, 1; error
	mov eax, 1
	int 0x80

	; Method with params and stack frame

	; params: eax=S, ebx=k, ecx=n
	; internal: edx=sum, ebp=A[n]

partition:
	cmp  ecx, ebx
	jge  .continue
	mov  eax, msg1; subset too small for k partitions
	call printLF
	jmp  error

.continue:

	; A[n] array defined from esp to esp-[n]
	; retn <- ebp A[n] is [ebp+esi+1]
	; n addresses down: <- esp

	;   save esp for later, and ebp can be used to reliably access the A array
	mov ebp, esp

	;preserve eax, ebx
	push      eax
	push      ebx

	;   find out how many bytes we need for arr
	mov eax, [n]
	mov ebx, 4
	mul ebx

	;   mov esp down by that much
	sub esp, eax

	;restore eax, ebx
	pop      ebx
	pop      eax

	push edx; preserve vars
	push ecx
	push eax

	push S
	push dword [n]
	call sum
	pop  eax
	mov  edx, 0
	mov  ecx, k
	div  ecx

	;   comment out line below might not need
	mov ecx, k; num elements
	mov esi, 0

.setupSumLeft:
	mov  [sumLeft+4*(ecx-1)], eax
	loop .setupSumLeft

	pop eax
	pop ecx
	pop edx

	; ; print eax
	; mov    eax, [sumLeft+4*0]
	; mov    ebx, buffer
	; call   int2str
	; mov    eax, buffer
	; call   printLF

	mov esp, ebp

	ret
subsetSum:
	; ebp reserved for A[n]
	
	call checkSum
	jnz .continue
	mov eax, 1
	ret
	.continue:
	
	ret

checkSum:
	push ecx
	mov ecx, k
	.L1:
		dec ecx
		cmp dword [sumLeft+4*ecx], 0
		jz .L2
		pop ecx
		ret
	.L2:
		test ecx, ecx
		jnz .L1

	pop ecx
	ret
