bits 64

decrypt_code_segment:
    push    rbp
    mov     rbp, rsp
    push    rbx
    push    rcx
    push    rdi
    push    r12
    push    r13

    mov     rbx, rdi                 ; Address of code segment
    mov     rcx, rsi                 ; Size of segment
    and     rcx, ~7                  ; Align size to 8 bytes
    
    mov     r12, r8                  ; First 8 bytes of key
    mov     r13, r9                  ; Last 8 bytes of key

.decrypt_segment_loop:
    test    rcx, rcx
    jz      .done
    
    mov     rdi, rbx                 ; block to decrypt
    mov     rsi, r12                 ; TEA Key
    mov     rdx, r13
    call    tea_decrypt_block
    
    add     rbx, 8                   ; Move forward to 8 bytes
    sub     rcx, 8                   ; Decrement counter
    jmp     .decrypt_segment_loop
    
.done:
    pop     r13
    pop     r12
    pop     rdi
    pop     rcx
    pop     rbx
    leave
    ret

tea_decrypt_block:
    push    rbp
    mov     rbp, rsp
    push    rbx
    push    rcx
    push    rdx
    push    r12
    push    r14

    mov     r14, rdi               ; r14 = Address where we want to decrypt 8 bytes

    ; Charger v0, v1 
    mov     eax, [rdi]             ; v0 = lower 4 bytes
    mov     ebx, [rdi + 4]         ; v1 = next 4 bytes

    ; Init sum (sum = 0xC6EF3720 for 32 loops)
    mov     edi, 0xC6EF3720        ; init sum

    ; delta constant de TEA
    mov     r11d, 0x9E3779B9       ; delta

    mov     r8d, esi               ; KEY[0]
    shr     rsi, 32
    mov     r9d, esi               ; KEY[1]

    mov     r10d, edx              ; KEY[2]
    shr     rdx, 32
    mov     r12d, edx              ; KEY[3]

    mov     ecx, 32                ; 32 tours de TEA

.decrypt_loop:
    ; v1 -= ((v0 << 4) + KEY[2]) ^ (v0 + sum) ^ ((v0 >> 5) + KEY[3]);

    mov     esi, eax               ; v0
    shl     esi, 4                 ; v0 << 4
    add     esi, r10d              ; (v0 << 4) + KEY[2]

    mov     edx, eax               ; v0
    add     edx, edi               ; v0 + sum

    xor     esi, edx               ; ((v0 << 4)+KEY[2]) ^ (v0+sum)

    mov     edx, eax               ; v0
    shr     edx, 5                 ; v0 >> 5
    add     edx, r12d              ; (v0 >> 5) + KEY[3]

    xor     esi, edx               ; ^ ((v0>>5)+KEY[3])
    sub     ebx, esi               ; v1 -= résultat

    ; v0 -= ((v1 << 4) + KEY[0]) ^ (v1 + sum) ^ ((v1 >> 5) + KEY[1]);

    mov     esi, ebx               ; v1
    shl     esi, 4                 ; v1 << 4
    add     esi, r8d               ; (v1 << 4) + KEY[0]

    mov     edx, ebx               ; v1
    add     edx, edi               ; v1 + sum

    xor     esi, edx               ; ((v1 << 4)+KEY[0]) ^ (v1+sum)

    mov     edx, ebx               ; v1
    shr     edx, 5                 ; v1 >> 5
    add     edx, r9d               ; (v1 >> 5) + KEY[1]

    xor     esi, edx               ; ^ ((v1>>5)+KEY[1])
    sub     eax, esi               ; v0 -= résultat

    ; sum -= delta
    sub     edi, r11d              ; sum -= delta

    dec     ecx
    jnz     .decrypt_loop

    mov     [r14], eax
    mov     [r14 + 4], ebx

    pop     r14
    pop     r12
    pop     rdx
    pop     rcx
    pop     rbx
    leave
    ret



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