%include 'print.asm'
%include 'read.asm'
%include 'convert.asm'
%include 'utils.asm'

	section .data
	S       dd 7, 3, 5, 12, 2, 1, 5, 3, 8, 4, 6, 4
	;       S       dd 3, 1, 5, 3
	Sbytes  equ ($-S)
	Ssize   equ 4

	k       equ 5
	;       messages
	msg1    db "k-partition of set S not possible", 0
	;       debug
	newline db "", 0
	dbug1   db "esi is -1", 0

	section .bss
	buffer  resb 1000
	n       resd 1; num elements in S (calculated at runtime)
	sumLeft resd k; for partition all 0's

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
	cmp  ecx, ebx; Impossible detection
	jge  .continue
	mov  eax, msg1; subset too small for k partitions
	call printLF
	jmp  error

.continue:; start of partition

	; A[n] array defined from esp to esp-[n]
	; retn <- ebp A[n] is [ebp+esi+1]
	; 12*4(48) btyes down: <- esp

	;   save esp for later, and ebp can be used to reliably access the A array
	mov ebp, esp

	;preserve eax, ebx
	push      eax
	push      ebx

	;   find out how many bytes we need for arr
	mov eax, [n]
	mov ebx, 4
	mul ebx

	; ; print eax
	; mov  ebx, buffer
	; call int2str
	; mov  eax, buffer
	; call printLF

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

.setupSumLeft:
	dec ecx
	mov [sumLeft+4*(ecx)], eax
	cmp ecx, 0
	jne .setupSumLeft

	pop eax
	pop ecx
	pop edx

	mov  esi, [n]
	dec  esi
	call subsetSum

	mov esp, ebp

	ret

printSumLeft:
	pushad
	push ecx

	mov ecx, k

.loop:
	dec ecx

	; pushad
	; mov  eax, [sumLeft+4*ecx]
	; mov  ebx, buffer
	; call int2str
	; mov  eax, buffer
	; call printLF
	; popad

	cmp ecx, 0
	jne .loop

	push eax
	mov  eax, newline
	call printLF
	pop  eax
	pop  ecx
	popad
	ret

	; sumLeft

subsetSum:
	; ebp reserved for A[n]
	; esi reserved for n

	call checkSum
	jnz  .cont1
	mov  eax, 1
	ret

.cont1:
	cmp  esi, 0
	jge  .cont2
	mov  eax, dbug1
	call printLF
	mov  eax, 0
	ret

.cont2:
	mov eax, 0; result = 0
	mov ecx, k; arrlen = k

.loop:
	; pushad
	; mov  eax, esi
	; mov  ebx, buffer
	; call int2str
	; mov  eax, buffer
	; call printLF
	; popad

	mov [ebp+(esi+1)*4], ecx; +1 bc ebp is retn address
	dec ecx

	; pushad
	; mov  eax, ecx
	; mov  ebx, buffer
	; call int2str
	; mov  eax, buffer
	; call printLF
	; popad

	; call printSumLeft

	mov eax, dword [sumLeft+ecx*4]
	cmp eax, dword [S+esi*4]
	jl  .cont3

	push dword [sumLeft+ecx*4]; preserve array value for later

	;    sumLeft[i] -= current item
	push eax; preserve eax
	mov  eax, [sumLeft+ecx*4]
	sub  eax, S[esi*4]
	mov  [sumLeft+ecx*4], eax
	pop  eax; preserve eax

	;    esi = n (recursion counter)
	push ecx
	push esi
	dec  esi
	call subsetSum
	pop  esi
	pop  ecx

	pop dword [sumLeft+ecx*4]

	;return early
	cmp     eax, 0
	je      .cont3
	ret

.cont3:

	cmp ecx, 0
	jg  .loop

	ret

	; checks if subsets all have sum/k sums

checkSum:
	push ecx
	mov  ecx, k

.L1:
	dec ecx
	cmp dword [sumLeft+ecx*4], 0
	jz  .L2
	pop ecx
	ret

.L2:
	test ecx, ecx
	jnz  .L1
	pop  ecx
	ret
