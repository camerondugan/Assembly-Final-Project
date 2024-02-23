section .txt

	; pushed in this order: Subset, n
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

	; .loop:
	; dec ecx
	
	; add eax, [ebx+ecx]
	
	; cmp ecx, 0
	; jne .loop

	pop ecx
	pop ebx
	pop eax
	mov eax, [esp+4]
	ret
