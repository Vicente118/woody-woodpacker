bits 64

%include "inc/syscall.inc"



global generate_tea_key
global get_tea_key
global tea_key 


section .bss
    tea_key:      resb 16   ; Random 16 bytes key

section .data
    urandom_path: db "/dev/urandom", 0
    
section .text

generate_tea_key:
    push    rbp
    mov     rbp, rsp
    push    rbx

    sys_open urandom_path, O_RDONLY, 0          ; Open /dev/urandom and stores fd in rbx
    test    rax, rax
    js      .error
    mov     rbx, rax

    sys_read rbx, tea_key, 0x10                 ; Read 16 bytes of /dev/urandom and stores it in tea_key
    test    rax, rax
    js      .error

    sys_close rbx
    jmp    .done

.error:
    mov     rax, 1

.done:
    xor     rax, rax
    pop     rbx
    leave 
    ret 


get_tea_key:
    lea     rax, [tea_key]
    ret