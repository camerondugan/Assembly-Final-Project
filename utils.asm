	;       Our Package for handling simple things programming langauges give by default
	section .txt

	; pushed in this order: Subset, (n elements)
	; byte array esp+20
	; n esp+16
	; ret
	; eax esp+8
	; ebx esp+4
	; ecx esp+0

sum:
	push eax
	push ebx
	push ecx

	;stack here: s n eax ecx
	mov    ebx, [esp+20]; subset
	mov    ecx, [esp+16]; n
	mov    eax, 0; sum

.loop:
	dec ecx
	add eax, dword [ebx+(ecx*4)]

	cmp ecx, 0
	jne .loop

	mov [esp+20], eax

	pop ecx
	pop ebx
	pop eax
	ret 4
