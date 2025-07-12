bits 64

extern code_segment_vaddr
extern code_segment_size
extern original_entry

global woody_stub
global woody_stub_size
global entry_offset
global tea_key_embedded
global tea_key_offset

%include "inc/syscall.inc"
%include "src/decrypt.s"

section .text 

woody_stub:
    push    rbp
    mov     rbp, rsp

    ; ========= "....WOODY...." ========== ;
    sys_write 1, woody_message, woody_message_len

    ; ========= DECRYPT CODE SEGMENT ========= ;
    mov     rdi, [rel code_segment_vaddr]
    mov     rsi, [rel code_segment_size]
    call    decrypt_code_segment

    ; ========= JUMP TO NEW ENTRYPOINT ========= ;
    mov     rax, [rel original_entry]
    jmp     rax



woody_message:      db "....WOODY....", 10, 0
woody_message_len:  equ $ - woody_message

tea_key_offset:     equ $ - woody_stub    
tea_key_embedded:   dq 0x1234567887654321   ; 16 bytes false key that we will replace just before decryption
                    dq 0x8765432112345678

entry_offset:       equ $ - woody_stub

woody_stub_end:
woody_stub_size:    equ woody_stub_end - woody_stub

