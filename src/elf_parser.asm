bits 64

%include "inc/elf64.inc"
%include "inc/syscall.inc"

global mmap_elf
global validate_elf
global parse_elf_headers
global find_code_segment
global find_injection_point
global modify_entry_point

section .data
    elf_magic: db 0x7f, "ELF", 0    ; Magic number ELF


section .text

validate_elf:
    push    rbp
    mov     rbp, rsp
    push    rbx
    mov     rbx, rdi                ; Save file_ptr in rbx

    ; Verify magic number
    mov     rsi, rdi                ; Store file pointer into rsi
    lea     rdi, [rel elf_magic]    ; Store address of elf_magic into rdi
    xor     rcx, rcx                ; Store 4 into rcx (Counter)

.loop
    mov     al, byte [rdi + rcx]
    mov     ah, byte [rsi + rcx]
    cmp     al, ah
    jne     .invalid_elf
    inc     rcx
    cmp     rcx, 4
    jne     .loop

    ; Verify type of file

    ; Verify endianness

    ; Verify type of ELF


.valid_elf:
    xor     rax, rax
    pop     rbx
    leave
    ret

.invalid_elf:
    mov     rax, 1
    pop     rbx
    leave
    ret




