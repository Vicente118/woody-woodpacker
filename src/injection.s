bits 64

%include "inc/elf64.inc"

global inject_stub
global patch_stub

; STUB OFFSET AND ADDRESSES
extern woody_stub
extern woody_stub_size
extern entry_offset_stub
extern code_segment_vaddr_offset_stub
extern code_segment_size_offset_stub
extern tea_key_offset_stub
extern modify_entry_point
extern injection_point_offset_stub
; Values we need to replace for placeholders from stub
extern original_entry
extern code_segment_vaddr
extern code_segment_size
extern tea_key
extern file_ptr
extern injection_point

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

    call    write_stub_to_cave

    call    modify_entry_point

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

    lea     rbx, [woody_stub]        ; Save address of stub
    
    mov     rdi, rbx
    and     rdi, ~0xFFF              ; Round to low boundary

    mov     rax, 10                  ; sys_mprotect
    mov     rdx, 7                   ; PROT_READ | PROT_WRITE | PROT_EXEC
    syscall

    ; === Patch Original Entrypoint === ;
    mov     rdx, [entry_offset_stub]
    mov     rax, [original_entry]
    mov     [rbx + rdx], rax

    ; === Patch Injection Point === ;
    mov     rdx, [injection_point_offset_stub]
    mov     rax, [injection_point]       ; Notre offset dans le fichier cible
    mov     [rbx + rdx], rax

    ; === Patch Code Segment Virtual Address === ; To know where we want to begin decryption in memory
    mov     rdx, [code_segment_vaddr_offset_stub]
    mov     rax, [code_segment_vaddr]
    mov     [rbx + rdx], rax

    ; === Patch Code Segment Size === ; To know how many bytes we want to decrypt
    mov     rdx, [code_segment_size_offset_stub]
    mov     rax, [code_segment_size]
    mov     [rbx + rdx], rax

    ; === Patch TEA Key 16 bytes === ;
    mov     rdx, [tea_key_offset_stub]
    mov     rax, [tea_key]
    mov     [rbx + rdx], rax        ; First 8 bytes of the key

    mov     rax, [tea_key + 8]
    mov     [rbx + rdx + 8], rax

    jmp     .done

.mprotect_failed:
    mov     rax, 60
    mov     rdi, 1
    syscall

.done:
    pop     rdx
    pop     rbx
    leave
    ret



; ====== Injection of stub into target file ===== ;

write_stub_to_cave:
    push    rbp
    mov     rbp, rsp
    push    rbx
    push    rcx
    push    rdi
    push    rsi

    ; ===== DESTINATION : Point d'injection calculé =====
    mov     rdi, [file_ptr]          ; début du fichier mappé
    add     rdi, [injection_point]   ; + offset d'injection
    
    ; ===== SOURCE : Stub patché =====
    lea     rsi, [woody_stub]        ; adresse du stub (déjà patché)
    
    ; ===== TAILLE : Taille du stub =====
    mov     rcx, 0x241                ; taille exacte

    ; ===== COPIER LE STUB =====
    rep     movsb                    ; Copier rcx bytes de rsi vers rdi
    
    ; ===== SUCCÈS =====
    xor     rax, rax

.done:
    pop     rsi
    pop     rdi
    pop     rcx
    pop     rbx
    leave
    ret