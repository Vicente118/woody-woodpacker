bits 64

; rsi = key (k)   -----  rdi = 64 bits to encrypt (v) 

global tea_encrypt_block

extern tea_key

section .data
    delta: dd 0x9e3779b9  ; delta = (√5–1)*231 


section .text 

tea_encrypt_block:
    push    rbp
    mov     rbp, rsp
    push    rbx
    push    rcx
    push    rdx

    mov     eax, [rdi]          ; v0 (First 32 bits we want to encrypt)
    mov     ebx, [rdi + 8]      ; v1 (Last 32 bits we want to encrypt)

    mov     ecx, [rsi]          ; k0 (First 32 bits of the key)
    mov     edx, [rsi + 4]      ; k1 (Second 32 bits of the key)
    mov     r8d, [rsi + 8]      ; k2 (Third 32 bits of the key)
    mov     r9d, [rsi + 12]     ; k3 (Last 32 bits of the key)

    xor     r10d, r10d          ; Sum
    mov     r11d, 32            ; 32 rounds

.encrypt_loop:
    add     r10d, [delta]

.done:
    xor     rax, rax
    pop     rdx
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