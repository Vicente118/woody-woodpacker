;; Syscalls

%define O_RDONLY 0
%define O_RDWR   2
%define O_CREAT  100  
%define O_TRUNC  1000

%define S_IWUSR  200

%macro sys_write 3  
    mov     rax, 1
    mov     rdi, %1
    mov     rsi, %2
    mov     rdx, %3
    syscall
%endmacro

%macro sys_read 3
    xor     rax, rax
    mov     rdi, %1
    mov     rsi, %2
    mov     rdx, %3
    syscall
%endmacro

%macro sys_exit 1
    mov     rax, 60
    mov     rdi, %1
    syscall
%endmacro

%macro sys_open 3       ;; Path, flags, mode
    mov     rax, 2
    mov     rdi, %1
    mov     rsi, %2
    mov     rdx, %3
    syscall
%endmacro

%macro sys_close 1
    mov     rax, 3
    mov     rdi, %1
    syscall
%endmacro

%macro sys_fstat 2
    mov     rax, 5
    mov     rdi, %1
    mov     rsi, %2
    syscall
%endmacro

%macro sys_mmap 4
    mov     rax, 9
    xor     rdi, rdi
    mov     rsi, [%1]
    mov     rdx, %2
    mov     r10, %3
    mov     r8,  [%4]
    xor     r9,  r9
    syscall
%endmacro

%macro sys_munmap 2
    mov     rax, 11
    mov     rdi, %1
    mov     rsi, %2
    syscall
%endmacro

%macro sys_unlink 1
    mov     rax, 87
    mov     rdi, %1
    syscall
%endmacro