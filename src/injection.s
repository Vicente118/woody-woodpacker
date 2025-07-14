bits 64

%include "inc/elf64.inc"

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
extern phdr_offset
extern phdr_size
extern code_segment_vaddr_offset
extern code_segment_size_offset

section .text

;-----------------------------------------------------------------------------
; inject_stub - Injects the decryption stub into the binary
;
; This function:
; 1. Finds the last LOAD segment in the ELF file
; 2. Calculates where to inject the stub (at end of this segment)
; 3. Extends the segment's size to include the stub
; 4. Copies the stub to the injection point
; 5. Updates the TEA key and original entry point in the stub
;
; Returns:
; - 0 on success
; - 1 on failure
;-----------------------------------------------------------------------------
inject_stub:
    push    rbp
    mov     rbp, rsp
    push    rbx
    push    r12
    push    r13
    push    r14




.error:
    mov     rax, 1                               ; Error code
    
.done:
    pop     r14
    pop     r13
    pop     r12
    pop     rbx
    leave
    ret