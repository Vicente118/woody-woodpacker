NAME = woody_woodpacker

NASM = nasm
NASMFLAGS = -f elf64
LD = ld
LDFLAGS = -m elf_x86_64

SRC_DIR = src
OBJ_DIR = obj
INCLUDE_DIR = include

SRC = $(wildcard $(SRC_DIR)/*.asm)
OBJ = $(patsubst $(SRC_DIR)/%.asm, $(OBJ_DIR)/%.o, $(SRC))


all: $(NAME)

$(NAME): $(OBJ_DIR) $(OBJ)
	$(LD) $(LDFLAGS) -o $@ $(OBJ)
	@echo "Compilation complete!"

$(OBJ_DIR):
	mkdir -p $(OBJ_DIR)

$(OBJ_DIR)/%.o: $(SRC_DIR)/%.asm
	$(NASM) $(NASMFLAGS) -I $(INCLUDE_DIR)/ -o $@ $<

clean:
	rm -rf $(OBJ_DIR)

fclean: clean
	rm -f $(NAME)
	rm -f woody

re: fclean all

test: all
	./$(NAME) sample

.PHONY: all clean fclean re test