default rel

global _start

section .data
str: db "Hello World!", 10

section .text
_start:
	push rbp
	mov rbp, rsp

	mov rax, 1
	mov rdi, 1
	lea rsi, [str]
	mov rdx, 13
	syscall

	pop rbp

	mov rax, 60
	xor rdi, rdi
	syscall
