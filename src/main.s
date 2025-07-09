bits 64

%include "inc/elf64.inc"
%include "inc/syscall.inc"

; Import functions
extern validate_elf
extern parse_elf_headers
extern find_code_segment

; Set variables to global
global original_entry
global phdr_offset
global phdr_count
global shdr_offset
global shdr_count
global code_segment_offset
global code_segment_size
global code_segment_vaddr
global injection_point

section .bss
    argc:               resq 1 ; Number of Arguments
    argv:               resq 1 ; Arguments
    fd:                 resq 1 ; File descriptor
    file_size:          resq 1 ; File size
    file_ptr:           resq 1 ; Pointer to the file mapped in memory
    original_entry:     resq 1 ; Entrypoint
    phdr_offset         resq 1
    phdr_count          resq 1
    shdr_offset         resq 1
    shdr_count          resq 1
    code_segment_offset resq 1
    code_segment_size   resq 1
    code_segment_vaddr  resq 1
    injection_point     resq 1

section .data 


section .text

global _start

_start:
    pop     qword [argc]            ; Store argc
    mov     qword [argv], rsp       ; Store argv

    cmp     qword [argc], 2         ; Check if argc == 2
    jne     .exit_failure           ; Jump to wrong_argc if argc != 2
    mov     rdi, [argv]             ; Store argv[0] in rdi
    mov     rdi, [rdi + 8]          ; Store argv[1] in rdi

.open_file:
    sys_open rdi, O_RDWR, 0         ; Open file argv[1] in rdi in Read Write mode
    test    rax, rax                ; If rax == 0
    js      .exit_failure           ; exit
    mov     [fd], rax               ; Store file descriptor in fd

.mmap_file:
    sub     rsp, 144                ; Reserve memory on stack for struct stat
    sys_fstat [fd], rsp             ; Call fstat
    test    rax, rax                ; Test if fstat worked
    js      .exit_failure

    mov     rax, [rsp + 48]         ; Store st_size in file_size
    mov     [file_size], rax

    ;; Map the file in memory
    sys_mmap file_size, 3, 1, fd    ; Call to mmap
    test    rax, rax
    js      .exit_failure
    mov     [file_ptr], rax         ; Store file pointer to file_ptr

    ;; Validate ELF file
    mov     rdi, file_ptr           ; Prepare rdi with file pointer
    call    validate_elf            ; Call to validate_elf
    test    rax, rax
    jnz     .exit_failure

    ;; Parse ELF File
    mov     rdi, file_ptr
    call    parse_elf_headers

    ;; Find code segment offset
    mov     rdi, file_ptr
    call    find_code_segment

.close_file:
    sys_close [fd]                  ; Close fd

.exit_success:
    sys_exit 0                      ; Exit success

.exit_failure:
    sys_exit 1          


;; [rsp]    = argc 
;; [rsp+8]  = argv[0]
;; [rsp+16] = argv[1]

; DB allocates in chunks of 1 byte.
; DW allocates in chunks of 2 bytes.
; DD allocates in chunks of 4 bytes.
; DQ allocates in chunks of 8 bytes.
; RESB 1 allocates 1 byte.
; RESW 1 allocates 2 bytes.
; RESD 1 allocates 4 bytes.
; RESQ 1 allocates 8 bytes.

; Function arguments: RDI - RSI - RDX - RCX - R8 - R9
; Syscall  arguments: RDI - RSI - RDX - R10 - R8 - R9

; entry       -> Entrypoint
; phdr_offset -> Offset where program headers begin
; phdr_count  -> Number of program header entries
; shdr_offset -> Offset where section headers begin
; shdr_count  -> Number of section header entires
; code_segment_offset -> Offset where the code segment begins
; code_segment_size   -> Size of the code segment
; code_segment_vaddr  -> Virtual address where the code segment will be loaded in memory
; injection_point     -> File offset where the decryption stub will be injected 