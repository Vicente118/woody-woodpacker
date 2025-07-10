bits 64

exte

global woody_stub
global woody_stub_size

section .data
    woody_message:      db "....WOODY....", 10, 0
    woody_message_len:  equ $ - woody_message
    tea_key_embedded:   dq 0x1234567887654321   ; 16 bytes false key that we will replace just before decryption
                        dq 0x8765432112345678
section .text 

woody_stub:
    push    rbp
    mov     rbp, rsp

    ; ========= "....WOODY...." ========== ;
    sys_write 1, woody_message, woody_message_len

    ; ========= DECRYPT CODE SEGMENT ========= ;