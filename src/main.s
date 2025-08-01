bits 64

%include "inc/elf64.inc"
%include "inc/syscall.inc"

; Import functions
extern validate_elf
extern parse_elf_headers
extern find_code_segment
extern generate_tea_key
extern get_tea_key
extern tea_encrypt_block
extern encrypt_code_segment
extern find_injection_point
extern inject_stub
extern modify_entry_point
extern woody_stub_size

; Set variables to global
global original_entry
global phdr_offset
global phdr_count
global phdr_size
global shdr_offset
global shdr_count
global code_segment_offset
global code_segment_size
global code_segment_vaddr
global injection_point
global file_ptr
global file_size
global new_entrypoint

section .bss
    argc:                resq 1 ; Number of Arguments
    argv:                resq 1 ; Arguments
    input_fd:            resq 1 ; File descriptor of original binary
    woody_fd:            resq 1 ; File descriptor of woody file at creation
    output_fd:           resq 1 ; File descriptor of woody to be modified
    file_size:           resq 1 ; File size
    file_ptr:            resq 1 ; Pointer to the file mapped in memory
    original_entry:      resq 1 ; Original entrypoint
    new_entrypoint:      resq 1 ; New entrypoint
    phdr_offset:         resq 1
    phdr_count:          resq 1
    phdr_size:           resq 1
    shdr_offset:         resq 1
    shdr_count:          resq 1
    code_segment_offset: resq 1
    code_segment_size:   resq 1
    code_segment_vaddr:  resq 1
    injection_point:     resq 1
    buffer               resb 4096 ; Buffer used for copying input file

section .data 
    woody_filename:      db "woody", 0

section .text

global _start

_start:
    pop     qword [argc]            ; Store argc
    mov     qword [argv], rsp       ; Store argv

    cmp     qword [argc], 2         ; Check if argc == 2
    jne     .exit_failure           ; Jump to wrong_argc if argc != 2
    mov     rdi, [argv]             ; Store *argv in rdi
    mov     rdi, [rdi + 8]          ; Store argv[1] in rdi

.open_file:
    sys_open rdi, O_RDWR, 0         ; Open file argv[1] in rdi in Read Write mode
    test    rax, rax                ; If rax == 0
    js      .exit_failure           ; exit
    mov     [input_fd], rax         ; Store file descriptor in fd

.get_file_size:
    sub     rsp, 144                ; Reserve memory on stack for struct stat
    sys_fstat [input_fd], rsp       ; Call fstat
    test    rax, rax                ; Test if fstat worked
    js      .exit_failure
    mov     rax, [rsp + 48]         ; Store st_size in file_size
    mov     [file_size], rax

.create_output_file:
    sys_open woody_filename, 0x242 , 0777o  ; O_RDWR | O_CREAT | O_TRUNC
    test    rax, rax
    js      .exit_failure
    mov     [woody_fd], rax         ; Put fd in woody_fd

.copy_file:
    mov     rbx, [file_size]        ; Total bytes in rbx
    xor     r12, r12                ; Bytes copied
    
.copy_loop:
    cmp     r12, rbx
    jge     .copy_done
    sys_read [input_fd], buffer, 4096
    test    rax, rax
    jle     .exit_failure
    mov     r13, rax
    sys_write [woody_fd], buffer, r13
    add     r12, rax 
    jmp     .copy_loop

.copy_done:
    sys_close [input_fd]

.mmap_file:
    ;; Map the file in memory
    sys_mmap file_size, 3, 1, woody_fd    ; Call to mmap
    test    rax, rax
    js      .exit_failure
    mov     [file_ptr], rax         ; Store file pointer to file_ptr

    ;; Validate ELF file
    lea     rdi, [file_ptr]         ; Prepare rdi with file pointer
    call    validate_elf            ; Call to validate_elf
    test    rax, rax
    jnz     .exit_failure

    ;; Parse ELF File
    lea     rdi, [file_ptr]
    call    parse_elf_headers

    ;; Find code segment offset
    lea     rdi, [file_ptr]
    call    find_code_segment
    test    rax, rax
    jnz     .exit_failure

    call    generate_tea_key         ; Random key generation
    test    rax, rax
    jnz     .exit_failure
    
    lea     rdi, [file_ptr]
    add     rdi, [code_segment_offset]
    call    encrypt_code_segment   ; Encrypt the whole code segment

    call    inject_stub

.close_file:
    sys_munmap [file_ptr], [file_size]
    sys_close [woody_fd]            ; Close fd

.exit_success:
    sys_exit 0                      ; Exit success

.exit_failure:
    sys_exit 1          
