[org 0x7c00]
[bits 16]

section code

;.init:
;   	mov eax, 0xb800
;	mov es, eax
;	mov eax, 0
;	mov ebx, 0 ; Index of character in string we are printing
;	mov ecx, 0 ; Address of character on screen
;	mov dl, 0 ; Actual value we are printing to the screen

;.clear:
;	mov byte [es:eax], 0 ; Move blank character to current text address
;	inc eax
;	mov byte [es:eax], 0x60 ; Move background color and text color to next address	
;	inc eax
;	
;	cmp eax, 2 * 25 * 80
;	jl .clear

;mov eax, text
;mov ecx, 3 * 2 * 80 ; Position the text to third row and fifth column
;push .end
;call .print
;
;jmp .switch
;
;.print:
;	mov dl, byte [eax + ebx]
;	
;	cmp dl, 0
;	je .print_end
;
;	mov byte [es:ecx], dl
;	inc ebx
;	inc ecx
;	inc ecx
;	
;	jmp .print
;
;.print_end:
;	mov eax, 0
;	ret
;
;.end:
;	jmp $

.switch:
	mov bx, 0x1000 ; Location of code on hard disk
	mov ah, 0x02
	mov al, 30 ; Number of sectors to read from hard disk
	mov ch, 0x00
	mov dh, 0x00
	mov cl, 0x02
	int 0x13

	cli ; Turn off the interrupts
	lgdt [gdt_descriptor] ; Load the GDT table
	
	mov eax, cr0
	or eax, 0x1
	mov cr0, eax ; Make switch to protected mode

	jmp code_seg:protected_start

text: db 'Welcome to MOS!', 0

[bits 32]
protected_start:
	mov ax, data_seg
	mov ds, ax
	mov ss, ax
	mov es, ax
	mov fs, ax
	mov gs, ax
	
	; Update stack pointer
	mov ebp, 0x90000
	mov esp, ebp

	call 0x1000
	jmp $

gdt_begin:
gdt_null_descriptor:
	dd 0x00
	dd 0x00
gdt_code_seg:
	dw 0xffff
	dw 0x00
	db 0x00
	db 10011010b
	db 11001111b
	db 0x00
gdt_data_seg:
	dw 0xffff
	dw 0x00
	db 0x00
	db 10010010b
	db 11001111b
	db 0x00
gdt_end:
gdt_descriptor:
	dw gdt_end - gdt_begin - 1
	dd gdt_begin

code_seg equ gdt_code_seg - gdt_begin
data_seg equ gdt_data_seg - gdt_begin

times 510 - ($ - $$) db 0x00 ; Pads the dile with 0s

db 0x55
db 0xaa
