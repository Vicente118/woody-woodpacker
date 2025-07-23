bits 64

global woody_stub
global woody_stub_size
global entry_offset_stub
global tea_key_offset_stub
global code_segment_vaddr_offset_stub 
global code_segment_size_offset_stub  
global code_segment_size_offset_stub
global tea_key_offset_stub

extern code_segment_vaddr


%include "inc/syscall.inc"
%include "src/decrypt.s"

section .data
entry_offset_stub:                dq original_entry - woody_stub            ; Offset where entrypoint in stored in stub
code_segment_vaddr_offset_stub:   dq code_segment_vaddr_stub - woody_stub   ; Offset where code segment virtual address is stored in stub 
code_segment_size_offset_stub:    dq code_segment_size - woody_stub         ; Offset where code segment size is stored in stub
tea_key_offset_stub:              dq tea_key - woody_stub                   ; Offset where the key is stored in stub
 
section .text 

woody_stub:
    push    rbp
    mov     rbp, rsp
    push    r13
    push    rdi
    push    rsi
    push    r8
    push    r9

    lea     r13, [rel woody_message]
    ; ========= "....WOODY...." ========== ;
    sys_write 1, r13, woody_message_len

    ; ========= DECRYPT CODE SEGMENT ========= ;
    ; mov     r8, [rel tea_key]      
    ; mov     r9, [rel tea_key + 8]   
    ; mov     rdi, [rel code_segment_vaddr_stub]
    ; mov     rsi, [rel code_segment_size]
    ; call    decrypt_code_segment

    pop     r9
    pop     r8
    pop     rsi
    pop     rdi
    pop     r13

    ; ========= JUMP TO ORIGINAL ENTRYPOINT ========= ;
    mov     rax, [rel original_entry]
    jmp     rax



woody_message:     db "....WOODY....", 10, 0
woody_message_len: equ $ - woody_message

original_entry:          dq 0    
code_segment_vaddr_stub: dq 0    
code_segment_size:       dq 0    
tea_key:                 dq 0,0  

woody_stub_end:
woody_stub_size: equ woody_stub_end - woody_stub        ; Size of the stub in bytes
