NC     = \033[0m
BLUE   = \033[1;34m
CYAN   = \033[1;36m
GREEN  = \033[1;32m
YELLOW = \033[1;33m

ASM = nasm
LD = ld

CFLAGS = -felf64
LDFLAGS = 

rwildcard = $(foreach d, $(wildcard $1*), $(call rwildcard, $d/, $2) $(filter $(subst *, %, $2), $d))

BUILD_DIR = build

OBJ_DIR = $(BUILD_DIR)/obj
SRC     = $(call rwildcard, src, *.asm)
OBJ     = $(patsubst src/%.asm, $(OBJ_DIR)/%.o, $(SRC))

EXE = $(BUILD_DIR)/bfasm

.PHONY: all clean

all: $(OBJ)
	@ echo -e "$(GREEN)LINKING EXECUTABLE$(NC) $(EXE)"
	@ $(LD) $(OBJ) -o $(EXE) $(LDFLAGS)

$(OBJ_DIR)/%.o: src/%.asm
	@ mkdir -p $(@D)
	@ echo -e "$(GREEN)COMPILING OBJECT$(NC) $@"
	@ $(ASM) $(CFLAGS) $< -o $@

clean:
	@ echo -e "$(YELLOW)CLEANING PROJECT$(NC)"
	@ rm -rf $(BUILD_DIR)
