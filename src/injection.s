bits 64

%include "inc/elf64.inc"

global inject_stub
global modify_entry_point
global patch_stub

; STUB OFFSET AND ADDRESSES
extern woody_stub
extern woody_stub_size
extern entry_offset_stub
extern code_segment_vaddr_offset_stub
extern code_segment_size_offset_stub
extern tea_key_offset_stub

; Values we need to replace for placeholders from stub
extern original_entry
extern code_segment_vaddr
extern code_segment_size
extern tea_key

section data:
section .text

inject_stub:
    push    rbp
    mov     rbp, rsp
    push    rbx
    push    r12
    push    r13
    push    r14

    call    patch_stub

    ; call    write_stub_to_cave

    ; call    modify_entry_point

    xor     rax, rax

.done:
    pop     r14
    pop     r13
    pop     r12
    pop     rbx 
    leave
    ret



patch_stub:
    push    rbp
    mov     rbp, rsp
    push    rbx
    push    rdx

    mov     rbx, woody_stub ; Save address of stub

    ; === Patch Original Entrypoint === ;
    mov     rdx, entry_offset_stub
    mov     rax, [original_entry]
    mov     [rbx + rdx], rax

    ; === Patch Code Segment Virtual Address === ; To know where we want to begin decryption in memory
    mov     rdx, code_segment_vaddr_offset_stub
    mov     rax, [code_segment_vaddr]
    mov     [rbx + rdx], rax

    ; === Patch Code Segment Size === ; To know how many bytes we want to decrypt
    mov     rdx, code_segment_size_offset_stub
    mov     rax, [code_segment_size]
    mov     [rbx + rdx], rax

    ; === Patch TEA Key 16 bytes === ;
    mov     rdx, tea_key_offset_stub
    mov     rax, [tea_key]
    mov     [rbx + rdx], rax        ; First 8 bytes of the key

    mov     rax, [tea_key + 8]
    mov     [rbx + rdx + 8], rax

    pop     rdx
    pop     rbx
    leave
    ret