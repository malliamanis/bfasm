%define CELLS_SIZE 30000

global bfasm_interpret

section .bss
cells: resb CELLS_SIZE

section .text

bfasm_interpret:
	ret
