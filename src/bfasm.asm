%define CELLS_SIZE 30000
%define OPERATIONS_SIZE 20000

%define LEFT     0
%define RIGHT    1
%define INC      2
%define DEC      3
%define OUT      4
%define IN       5
%define JMP_FWD  6
%define JMP_BACK 7
%define EOF      8

global bfasm_interpret

section .bss
cells: resb CELLS_SIZE

; the higher 16 bits are for the jump index for JMP_FWD and JMP_BACK and the lower 16 bits are the operation IDs
operations: resd OPERATIONS_SIZE

section .text

; rdi has source code
compile_generic:
	mov r8, rdi           ; pointer to source

	xor r9, r9            ; operations index
	lea r10, [operations]

source_loop:
	mov bl, byte [r8]

	cmp bl, 0
	je source_loop_end

source_left:
	cmp bl, '<'
	jne source_right

	mov word [r10 + r9 * 4 + 2], LEFT
	inc r9
	
	jmp source_loop_continue

source_right:
	cmp bl, '>'
	jne source_inc

	mov word [r10 + r9 * 4 + 2], RIGHT
	inc r9

	jmp source_loop_continue

source_inc:
	cmp bl, '+'
	jne source_dec

	mov word [r10 + r9 * 4 + 2], INC
	inc r9

	jmp source_loop_continue

source_dec:
	cmp bl, '-'
	jne source_out

	mov word [r10 + r9 * 4 + 2], DEC
	inc r9

	jmp source_loop_continue

source_out:
	cmp bl, '.'
	jne source_in

	mov word [r10 + r9 * 4 + 2], OUT
	inc r9

	jmp source_loop_continue

source_in:
	cmp bl, ','
	jne source_jmp_fwd

	mov word [r10 + r9 * 4 + 2], IN
	inc r9

	jmp source_loop_continue

source_jmp_fwd:
	cmp bl, '['
	jne source_jmp_back

	push r9
	mov word [r10 + r9 * 4 + 2], JMP_FWD

	jmp source_loop_continue

source_jmp_back:
	cmp bl, ']'
	jne source_loop_continue
	
	mov word [r10 + r9 * 4 + 2], JMP_BACK

	pop r11
	mov word [r10 + r11 * 4], r9w
	mov word [r10 + r9 * 4], r11w
	inc r9

source_loop_continue:
	inc r8
	jmp source_loop

source_loop_end:
	mov word [r10 + r9 * 4 + 2], EOF
	ret

; rdi has the source
bfasm_interpret:
	call compile_generic

	lea r8, [cells + 1]             ; data pointer
	
	xor r9, r9                      ; operation iterator
	lea r10, [operations]

program_loop:
	cmp r8, cells
	jle skip

skip:

	mov bx, word [r10 + r9 * 4 + 2] ; the operation type

	cmp bx, EOF
	je program_loop_end

program_left:
	cmp bx, LEFT
	jne program_right

	dec r8

	jmp program_loop_continue

program_right:
	cmp bx, RIGHT
	jne program_inc

	inc r8

	jmp program_loop_continue

program_inc:
	cmp bx, INC
	jne program_dec

	inc byte [r8]

	jmp program_loop_continue

program_dec:
	cmp bx, DEC
	jne program_out
	
	dec byte [r8]

	jmp program_loop_continue

program_out:
	cmp bx, OUT
	jne program_in

	mov rax, 1
	mov rdi, 1
	mov rsi, r8
	mov rdx, 1
	syscall

	jmp program_loop_continue

program_in:
	cmp bx, IN
	jne program_jmp_fwd

	mov rax, 0
	mov rdi, 0
	mov rsi, r8
	mov rdx, 1
	syscall

	jmp program_loop_continue

program_jmp_fwd:
	cmp bx, JMP_FWD
	jne program_jmp_back

	cmp byte [r8], 0
	jne program_loop_continue

	mov r9w, word [r10 + r9 * 4] ; jump to index of matching ']'
	jmp program_loop_continue

program_jmp_back:
	cmp bx, JMP_BACK
	jne program_loop_continue

	cmp byte [r8], 0
	je program_loop_continue

	mov r9w, word [r10 + r9 * 4]

program_loop_continue:
	inc r9
	jmp program_loop

program_loop_end:
	ret
