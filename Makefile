NAME = woody_woodpacker

NASM = nasm
NASMFLAGS = -f elf64
LD = ld
LDFLAGS = -m elf_x86_64

SRC_DIR = src
OBJ_DIR = obj
INCLUDE_DIR = inc

SRC = src/main.s src/elf_parser.s src/encrypt.s src/utils.s
OBJ = $(patsubst $(SRC_DIR)/%.s, $(OBJ_DIR)/%.o, $(SRC))


all: $(NAME)

$(NAME): $(OBJ_DIR) $(OBJ)
	$(LD) $(LDFLAGS) -o $@ $(OBJ)
	@echo "Woody is ready !"

$(OBJ_DIR):
	mkdir -p $(OBJ_DIR)

$(OBJ_DIR)/%.o: $(SRC_DIR)/%.s
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