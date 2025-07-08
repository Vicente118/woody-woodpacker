struc WoodyContext
    .file_size:     resq 1      ; File size
    .file_hdr:      resq 1      ; Pointer to the ELF header
    .program_hdr:   resq 1      ; Pointer to the program header
    .section_hdr:   resq 1      ; Pointer   
endstruc