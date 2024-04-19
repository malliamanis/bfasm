default rel

global _start

section .data
size: dq 30000
newline: db 10

section .bss
cells: resq 1
pointer: resq 1

section .text

; prints null-terminated strings
print: ; rdi contains the string
	mov rsi, rdi

print_loop:
	; print character
	mov rax, 1
	mov rdi, 1
	mov rdx, 1
	syscall

	; increment pointer and check if the char is 0
	inc rsi
	mov al, byte [rsi]
	cmp al, 0
	jne print_loop

	ret

_start:
	push rbp
	mov rbp, rsp

	mov r8, qword [rsp + 8] ; argc

	xor r9, 0 ; iterator
arg_loop:
	mov rdi, qword [rsp + 16 + 8 * r9] ; argv[iterator]
	call print

	mov rax, 1
	mov rdi, 1
	lea rsi, [newline]
	mov rdx, 1
	syscall

	inc r9
	cmp r9, r8

	jne arg_loop

	; quit
	pop rbp

	mov rax, 60
	mov rdi, 0
	syscall
