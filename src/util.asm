default rel

global exit_ ; underscore so it doesn't conflict with exit in libc
global print
global file_read

section .data
file_err: db "error: cannot open file", 10, 0

section .text

; rdi has the exit code
exit_:
	mov rax, 60
	syscall
	ret

; prints null-terminated strings
; rdi contains the string
print:
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

; rdi has file name
; rsi has buffer
; rdx has max size
file_read:
	push rdi       ; keep to close the file
	push rdx
	push rsi

	; open file
	mov rax, 2     ; SYS_OPEN
	;   rdi        ; file name
	mov rsi, 0     ; O_RDONLY
	mov rdx, 0o644 ; file permission
	syscall 

	mov rdi, rax
	pop rsi        ; buffer
	; I am relying on the kernel not continuing to read once it reaches the end of the file
	pop rdx        ; amount to read 
	mov rax, 0     ; SYS_READ
	syscall

	mov rax, 3     ; SYS_CLOSE
	pop rdi
	syscall
	
	ret
