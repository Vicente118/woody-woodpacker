; ELF64 Header Structure
struc Elf64_Ehdr
    .e_ident:        resb 16  ; ELF identification
    .e_type:         resw 1   ; Object file type
    .e_machine:      resw 1   ; Machine type
    .e_version:      resd 1   ; Object file version
    .e_entry:        resq 1   ; Entry point address
    .e_phoff:        resq 1   ; Program header offset
    .e_shoff:        resq 1   ; Section header offset
    .e_flags:        resd 1   ; Processor-specific flags
    .e_ehsize:       resw 1   ; ELF header size
    .e_phentsize:    resw 1   ; Size of program header entry
    .e_phnum:        resw 1   ; Number of program header entries
    .e_shentsize:    resw 1   ; Size of section header entry
    .e_shnum:        resw 1   ; Number of section header entries
    .e_shstrndx:     resw 1   ; Section name string table index
endstruc

; Program Header Structure
struc Elf64_Phdr
    .p_type:         resd 1   ; Segment type
    .p_flags:        resd 1   ; Segment flags
    .p_offset:       resq 1   ; Segment file offset
    .p_vaddr:        resq 1   ; Segment virtual address
    .p_paddr:        resq 1   ; Segment physical address
    .p_filesz:       resq 1   ; Segment size in file
    .p_memsz:        resq 1   ; Segment size in memory
    .p_align:        resq 1   ; Segment alignment
endstruc

; Section Header Structure
struc Elf64_Shdr
    .sh_name:        resd 1   ; Section name
    .sh_type:        resd 1   ; Section type
    .sh_flags:       resq 1   ; Section attributes
    .sh_addr:        resq 1   ; Virtual address in memory
    .sh_offset:      resq 1   ; Offset in file
    .sh_size:        resq 1   ; Size of section
    .sh_link:        resd 1   ; Link to other section
    .sh_info:        resd 1   ; Misc info
    .sh_addralign:   resq 1   ; Address alignment boundary
    .sh_entsize:     resq 1   ; Size of entries
endstruc

; ELF Identification Constants
%define EI_MAG0     0         ; Magic number index 0
%define EI_MAG1     1         ; Magic number index 1
%define EI_MAG2     2         ; Magic number index 2
%define EI_MAG3     3         ; Magic number index 3
%define EI_CLASS    4         ; File class
%define EI_DATA     5         ; Data encoding
%define EI_VERSION  6         ; File version
%define EI_OSABI    7         ; OS/ABI identification
%define EI_ABIVERSION 8       ; ABI version
%define EI_PAD      9         ; Start of padding bytes
%define EI_NIDENT   16        ; Size of e_ident[]

%define e_type      0x10

%define BIT32       0x1
%define BIT64       0x2

%define LENDIAN     1
%define BENDIAN     2

; ELF Magic Numbers
%define ELFMAG0     0x7F      ; e_ident[EI_MAG0]
%define ELFMAG1     'E'       ; e_ident[EI_MAG1]
%define ELFMAG2     'L'       ; e_ident[EI_MAG2]
%define ELFMAG3     'F'       ; e_ident[EI_MAG3]

; ELF Class Types
%define ELFCLASS64  2         ; 64-bit objects

; Segment Types
%define PT_LOAD     1         ; Loadable segment
%define PT_DYNAMIC  2         ; Dynamic linking information
%define PT_INTERP   3         ; Interpreter pathname
%define PT_NOTE     4         ; Auxiliary information

; Segment Permissions
%define PF_X        0x1       ; Executable
%define PF_W        0x2       ; Writable
%define PF_R        0x4       ; Readable

; Object File Types
%define ET_EXEC     0x2
%define ET_DYN      0x3