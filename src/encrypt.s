bits 64

; rsi = key (k)   -----  rdi = 64 bits to encrypt (v) 

global  encrypt_code_segment

extern  tea_key
extern  file_ptr
extern  code_segment_offset
extern  code_segment_size

section .data
    delta: dd 0x9e3779b9  ; delta = (√5–1)*231 


section .text 

tea_encrypt_block:
    push    rbp
    mov     rbp, rsp
    push    rbx
    push    rcx
    push    rdx
    push    r12

    mov     r12, rdi 
    mov     eax, [rdi]          ; v0 (First 32 bits we want to encrypt)
    mov     ebx, [rdi + 4]      ; v1 (Last 32 bits we want to encrypt)

    mov     ecx, [tea_key]          ; k0 (First 32 bits of the key)
    mov     edx, [tea_key + 4]      ; k1 (Second 32 bits of the key)
    mov     r8d, [tea_key + 8]      ; k2 (Third 32 bits of the key)
    mov     r9d, [tea_key + 12]     ; k3 (Last 32 bits of the key)

    xor     r10d, r10d          ; Sum
    mov     r11d, 32            ; 32 rounds

.encrypt_loop:
    add     r10d, [delta]

    ; v0 += ((v1 << 4) + k0) ^ (v1 + sum) ^ ((v1 >> 5) + k1)
    mov     esi, ebx            ; Put v1 into esi
    shl     esi, 4              ; (v1<<4)
    add     esi, ecx            ; + k0

    mov     edi, ebx            ; Store v1 into edi
    add     edi, r10d           ; v1 += add
    xor     esi, edi            ; Result of (v1<<4) + k0) ^ (v1 + sum)

    mov     edi, ebx            ; Store v1 into edi
    shr     edi, 5              ; v1 >> 5
    add     edi, edx            ; + k1
    xor     esi, edi            ; Last XOR

    add     eax, esi            ; v0 += result

    ; v1 += ((v0<<4) + k2) ^ (v0 + sum) ^ ((v0>>5) + k3)
    mov     esi, eax
    shl     esi, 4
    add     esi, r8d

    mov     edi, eax
    add     edi, r10d
    xor     esi, edi

    mov     edi, eax
    shr     edi, 5
    add     edi, r9d
    xor     esi, edi

    add     ebx, esi

    ; Loop again (32 times in total
    dec     r11d
    jnz     .encrypt_loop

    ; Store result back
    mov     [r12], eax          ; Store encrypted v0
    mov     [r12 + 4], ebx      ; Store encrypted v1
    ; We successfully encrypted 64 bits (8 bytes)

    pop     r12
    pop     rdx
    pop     rcx
    pop     rbx
    leave 
    ret


;---------- Encrypt whole code segment -------------

encrypt_code_segment:
    push    rbp
    mov     rbp, rsp
    push    rbx
    push    rcx
    push    rdi


    mov     rbx, [file_ptr]                 ; Load pointer to the file
    add     rbx, [code_segment_offset]      ; Add code segment offset to pointer
    mov     rcx, [code_segment_size]        ; Store size of code segment into rcx
    and     rcx, ~7                         ; Align size to 8 bytes: (size + 8 - 1) & ~(8 - 1)


.encrypt_segment_loop:
    test    rcx, rcx
    jz      .done 

    mov     rdi, rbx                        ; Put pointer to code segment in rdi (The key is already in rsi)
    call    tea_encrypt_block           

    add     rbx, 8                          ; Step of 8 bytes in code segment
    sub     rcx, 8                          ; decrement counter
    jmp     .encrypt_segment_loop


.done:
    xor     rax, rax
    pop     rdi 
    pop     rcx
    pop     rbx
    leave
    ret







; uint32_t KEY[4];  // Key space for bit shifts

; void encrypt(uint32_t *v) 
; {
;   uint32_t v0 = v[0], v1 = v[1], sum = 0;             // set up
;   uint32_t delta = 0x9e3779b9;                        // a key schedule constant

;   for (int i = 0; i < 32; i++) 
;   {                                                   // basic cycle start
;     sum += delta;
;     v0 += ((v1 << 4) + KEY[0]) ^ (v1 + sum) ^ ((v1 >> 5) + KEY[1]);
;     v1 += ((v0 << 4) + KEY[2]) ^ (v0 + sum) ^ ((v0 >> 5) + KEY[3]);  
;   }                                                   // end cycle 
;   v[0] = v0; 
;   v[1] = v1;
; }       

; void decrypt (uint32_t* v) 
; {
;     uint32_t v0 = v[0], v1 = v[1], sum = 0xC6EF3720;  // set up 
;     uint32_t delta = 0x9e3779b9;                        // a key schedule constant 

;     for (int i = 0; i < 32; i++) 
;     {                                                 // basic cycle start 
;         v1 -= ((v0 << 4) + KEY[2]) ^ (v0 + sum) ^ ((v0 >> 5) + KEY[3]);
;         v0 -= ((v1 << 4) + KEY[0]) ^ (v1 + sum) ^ ((v1 >> 5) + KEY[1]);
;         sum -= delta;
;     }                                                 // end cycle 
;     v[0] = v0; 
;     v[1] = v1;
; }