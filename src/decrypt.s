bits 64

extern tea_key_embedded

decrypt_code_segment:
    push    rbp
    mov     rbp, rsp
    push    rbx
    push    rcx
    push    rdi
    
    mov     rbx, rdi                 ; Adresse du segment de code
    mov     rcx, rsi                 ; Taille du segment
    and     rcx, ~7                  ; Aligner la taille sur 8 octets
    
.decrypt_segment_loop:
    test    rcx, rcx
    jz      .done
    
    mov     rdi, rbx                 ; Bloc à décrypter
    lea     rsi, [rel tea_key_embedded] ; Clé TEA
    call    tea_decrypt_block
    
    add     rbx, 8                   ; Avancer de 8 octets
    sub     rcx, 8                   ; Décrémenter le compteur
    jmp     .decrypt_segment_loop
    
.done:
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
    
    mov     r12, rdi              
    
    ; Load v0, v1
    mov     eax, [rdi]             ; v0
    mov     ebx, [rdi + 4]         ; v1
    
    ; Init sum (sum = 0xC6EF3720 for 32 loops)
    mov     edi, 0xC6EF3720        ; sum
    
    ; Load delta
    mov     r9d, 0x9E3779B9        ; delta
    
    ; Load key
    mov     r8, rsi                ; Key 
    
    ; Iterations
    mov     r11d, 32             
    
.decrypt_loop:
    ; v1 -= ((v0 << 4) + KEY[2]) ^ (v0 + sum) ^ ((v0 >> 5) + KEY[3]);
    mov     ecx, eax               ; v0
    shl     ecx, 4                 ; v0 << 4
    add     ecx, [r8 + 8]          ; (v0 << 4) + KEY[2]
    
    mov     edx, eax               ; v0
    add     edx, edi               ; v0 + sum
    
    xor     ecx, edx               ; ((v0 << 4) + KEY[2]) ^ (v0 + sum)
    
    mov     edx, eax               ; v0
    shr     edx, 5                 ; v0 >> 5
    add     edx, [r8 + 12]         ; (v0 >> 5) + KEY[3]
    
    xor     ecx, edx               ; ((v0 << 4) + KEY[2]) ^ (v0 + sum) ^ ((v0 >> 5) + KEY[3])
    sub     ebx, ecx               ; v1 -= ...
    
    ; v0 -= ((v1 << 4) + KEY[0]) ^ (v1 + sum) ^ ((v1 >> 5) + KEY[1]);
    mov     ecx, ebx               ; v1
    shl     ecx, 4                 ; v1 << 4
    add     ecx, [r8]              ; (v1 << 4) + KEY[0]
    
    mov     edx, ebx               ; v1
    add     edx, edi               ; v1 + sum
    
    xor     ecx, edx               ; ((v1 << 4) + KEY[0]) ^ (v1 + sum)
    
    mov     edx, ebx               ; v1
    shr     edx, 5                 ; v1 >> 5
    add     edx, [r8 + 4]          ; (v1 >> 5) + KEY[1]
    
    xor     ecx, edx               ; ((v1 << 4) + KEY[0]) ^ (v1 + sum) ^ ((v1 >> 5) + KEY[1])
    sub     eax, ecx               ; v0 -= ...
    
    ; sum -= delta
    sub     edi, r9d               ; sum -= delta
    
    ; Boucler
    dec     r11d
    jnz     .decrypt_loop
    
    ; Stocker les résultats
    mov     [r12], eax             ; v0
    mov     [r12 + 4], ebx         ; v1
    
    pop     r12
    pop     rdx
    pop     rcx
    pop     rbx
    leave
    ret