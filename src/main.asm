%define FILE_MAX_SIZE 20000

default rel

extern exit_
extern print
extern file_read

extern bfasm_interpret

global _start

section .data
arg_err: db "error: no input files", 10, 0

section .bss
file_buffer: resb FILE_MAX_SIZE

section .text

_start:
	push rbp
	mov rbp, rsp

	cmp qword [rsp + 8], 2 ; argc
	jge _start_has_files

	; if it doesn't have files

	lea rdi, [arg_err]
	call print

	mov rdi, 1
	call exit_

_start_has_files:
	mov rdi, qword [rsp + 16 + 8] ; argv[1] file name
	lea rsi, [file_buffer]
	mov rdx, FILE_MAX_SIZE
	call file_read

	mov rdi, rsi
	call print

	; quit
	pop rbp

	xor rdi, rdi
	call exit_
