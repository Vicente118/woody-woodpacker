bits 64

%include "inc/elf64.inc"
%include "inc/syscall.inc"

; Set functions global
global validate_elf
global parse_elf_headers
global find_code_segment
global find_injection_point
global modify_entry_point

; Get external declaration to this file
extern original_entry
extern phdr_offset
extern phdr_count
extern phdr_size
extern shdr_offset
extern shdr_count
extern code_segment_offset 
extern code_segment_size   
extern code_segment_vaddr  
extern injection_point


section .data
    elf_magic:  db 0x7f, "ELF", 0    ; Magic number ELF
    wrong_arch: db "Error: only 64 bit architecture are supported", 0x0a

section .text

; ------------- validate_elf -----------------
validate_elf:
    push    rbp
    mov     rbp, rsp
    push    rbx
    push    rdi
    push    rsi

    ; Verify magic number
    mov     rbx, rdi                ; Store file pointer into rbx
    mov     rdi, [rbx]              
    lea     rsi, [rel elf_magic]    ; Store address of elf_magic into rdi
    xor     rcx, rcx

.loop:
    mov     al, byte [rdi + rcx]    ; Compare byte by byte 0x7f, "ELF"
    mov     ah, byte [rsi + rcx]
    cmp     al, ah
    jne     .invalid_elf
    inc     rcx
    cmp     rcx, 4
    jl     .loop                    ; Jump if rcx less than 4

    ; Verify architecture
    mov     al, byte [rdi + EI_CLASS]      ; Check architecture
    cmp     al, BIT64
    jne     .invalid_arch

    ; Verify endianness (Only little-endian is needed)
    mov     al, byte [rdi + EI_DATA]
    cmp     al, LENDIAN
    jne     .invalid_elf

    ; Verify type of ELF
    mov     ax, word [rdi + Elf64_Ehdr.e_type]
    cmp     ax, ET_EXEC
    je      .valid_elf
    cmp     ax, ET_DYN
    je      .valid_elf
    jmp     .invalid_elf

.valid_elf:
    xor     rax, rax
    pop     rsi 
    pop     rdi
    pop     rbx
    leave
    ret

.invalid_elf:
    mov     rax, 1
    pop     rsi 
    pop     rdi
    pop     rbx
    leave
    ret

.invalid_arch:
    mov     rax, 1
    pop     rsi 
    pop     rdi
    pop     rbx
    sys_write 1, wrong_arch, 47
    leave
    ret
    
; ------------- parse_elf_headers -----------------
parse_elf_headers:
    push    rbp
    mov     rbp, rsp
    push    rbx
    mov     rbx, [rdi]            ; Save file_ptr into rbx

    ; Extract entrypoint
    mov     rax, [rbx + Elf64_Ehdr.e_entry]
    mov     [original_entry], rax

    ; Extract phdr_offset and phdr_count
    mov     rax, [rbx + Elf64_Ehdr.e_phoff]
    mov     [phdr_offset], rax
    movzx   rax, word [rbx + Elf64_Ehdr.e_phnum]  ; movzx fill with 0 the highest bytes
    mov     [phdr_count], rax

    ; Extract shdr_offset and shdr_count
    mov     rax, [rbx + Elf64_Ehdr.e_shoff]
    mov     [shdr_offset], rax
    movzx   rax, word [rbx + Elf64_Ehdr.e_shnum]
    mov     [shdr_count], rax

    movzx   rax, word [rbx + Elf64_Ehdr.e_phentsize]
    mov     [phdr_size], rax

    xor     rax, rax
    pop     rbx
    leave
    ret




;-------------- find_code_segment ----------------
; 1. Loop through every program headers
; 2. Look for segment of type PT_LOAD (Loaded in memory)
; 3. Check that PT_LOAD has flag PF_X (Executable)
; 4. Stores informations: code_segment_offset, code_segment_size code_segment_vaddr

find_code_segment:
    push    rbp
    mov     rbp, rsp
    push    rbx
    push    rdx
    
    mov     rbx, [rdi]              ; Store file pointer in rbx
    add     rbx, [phdr_offset]      ; Add program header offset so rbx points to them
    xor     rcx, rcx                ; Init a counter
    mov     rdx, [phdr_count]       ; Put number of program headers in rdx

.loop_segments:
    cmp     rcx, rdx
    jge     .segment_not_found      ; Jump if rcx is greater or equal to rbx
    
    mov     eax, [rbx + Elf64_Phdr.p_type]     ; EAX because we look for the 4 least significant bytes
    cmp     eax, PT_LOAD                       ; Check if type is PT_LOAD
    jne     .next_segment

    mov     eax, [rbx + Elf64_Phdr.p_flags]    
    and     eax, PF_X                          ; Check if the segment is executable
    jz      .next_segment

    ; We found code segment, we can retrieve necessary informations

    mov     rax, [rbx + Elf64_Phdr.p_offset]   ; Offset until code segment
    mov     [code_segment_offset], rax

    mov     rax, [rbx + Elf64_Phdr.p_filesz]   ; Size of the segment in file
    mov     [code_segment_size], rax

    mov     rax, [rbx + Elf64_Phdr.p_vaddr]    ; Virtual address of this segment
    mov     [code_segment_vaddr], rax
    
    xor     rax, rax
    jmp    .done

.next_segment:
    add     rbx, [phdr_size]
    inc     rcx
    jmp     .loop_segments

.segment_not_found:
    mov     rax, 1

.done:
    pop     rdx
    pop     rbx
    leave
    ret

