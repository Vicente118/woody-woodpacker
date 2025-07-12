bits 64

global inject_stub
global modify_entry_point

extern file_ptr
extern file_size
extern injection_point
extern original_entry
extern tea_key
extern tea_key_offset
extern woody_stub
extern woody_stub_size
extern code_segment_vaddr
extern code_segment_size
extern entry_offset

section .text

inject_stub:
    push    rbp
    mov     rbp, rsp 

    ; Load size of stub
    mov     rcx, woody_stub_size

    ; Copy stub a injection point
    mov     rdi, [file_ptr]
    add     rdi, [injection_point]
    lea     rsi, [rel woody_stub]
    rep     movsb                   ; Copy stub bytes by bytes

    ; Load TEA key for decryption
    mov     rdi, [file_ptr]
    add     rdi, [injection_point]
    add     rdi, tea_key_offset       ; We are exactly where the key is stored in the stub injected

    mov     rsi, tea_key
    mov     rax, [rsi]
    mov     [rdi], rax             ; First 8 bytes of the key
    mov     rax, [rsi + 8]
    mov     [rdi + 8], rax          ; Last 8 bytes of the key

    ; Change entrypoint
    mov     rdi, [file_ptr]
    add     rdi, [injection_point]

    add     rdi, entry_offset
    mov     rax, [original_entry]
    mov     [rdi], rax


    xor     rax, rax
    leave
    ret