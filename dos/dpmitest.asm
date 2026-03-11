; dpmitest.com - Detect DPMI server and switch to protected mode
; Assemble: nasm -f bin -o dpmitest.com dpmitest.asm
org 100h

start:
    ; Detect DPMI (INT 2Fh AX=1687h)
    mov ax, 1687h
    int 2Fh
    test ax, ax
    jnz .no_dpmi

    ; DPMI found! Save entry point (ES:DI), host data size (SI), flags (BX)
    mov [entry_off], di
    mov [entry_seg], es
    mov [host_para], si
    mov [dpmi_flags], bx
    mov [dpmi_ver_major], dh
    mov [dpmi_ver_minor], dl
    mov [dpmi_cpu], cl

    ; Print detection message
    mov ah, 09h
    mov dx, msg_found
    int 21h

    ; Print DPMI version
    mov ah, 09h
    mov dx, msg_ver
    int 21h
    mov dl, [dpmi_ver_major]
    add dl, '0'
    mov ah, 02h
    int 21h
    mov dl, '.'
    mov ah, 02h
    int 21h
    mov dl, [dpmi_ver_minor]
    add dl, '0'
    mov ah, 02h
    int 21h

    ; Print CPU type
    mov ah, 09h
    mov dx, msg_cpu
    int 21h
    mov dl, [dpmi_cpu]
    add dl, '0'
    mov ah, 02h
    int 21h

    ; Print 32-bit support flag
    mov ah, 09h
    mov dx, msg_crlf
    int 21h

    test word [dpmi_flags], 1
    jnz .has_32bit
    mov ah, 09h
    mov dx, msg_16only
    int 21h
    jmp .try_16bit
.has_32bit:
    mov ah, 09h
    mov dx, msg_32bit
    int 21h

    ; Allocate private data for DPMI host
    mov bx, [host_para]
    test bx, bx
    jz .skip_alloc32
    mov ah, 48h
    int 21h
    jc .no_mem
    mov es, ax
.skip_alloc32:

    ; Switch to 32-bit protected mode
    mov ax, 1           ; 1 = 32-bit client
    call far [entry_off]
    jc .pm_fail32

    ; We're in 32-bit protected mode!
    mov ah, 09h
    mov dx, msg_pm32
    int 21h

    ; Test INT 31h AX=0400h - Get DPMI version
    mov ax, 0400h
    int 31h
    jc .skip_ver

    ; AH=major, AL=minor version
    push ax
    mov ah, 09h
    mov dx, msg_dpmi_ver
    int 21h
    pop ax

    ; Print major version digit
    push ax
    mov dl, ah
    add dl, '0'
    mov ah, 02h
    int 21h
    mov dl, '.'
    mov ah, 02h
    int 21h
    pop ax

    ; Print minor version digit
    mov dl, al
    add dl, '0'
    mov ah, 02h
    int 21h

    mov ah, 09h
    mov dx, msg_crlf
    int 21h

.skip_ver:
    ; Test INT 31h AX=0500h - Get free memory info
    mov ax, 0500h
    push es
    push ds
    pop es          ; ES = DS (our data segment)
    mov edi, meminfo
    int 31h
    pop es
    jc .skip_mem

    ; Print largest free block
    mov ah, 09h
    mov dx, msg_free
    int 21h

    ; Print the value in decimal (first dword = largest free block in bytes)
    mov eax, [meminfo]
    shr eax, 10     ; Convert to KB
    call print_dec

    mov ah, 09h
    mov dx, msg_kb
    int 21h

.skip_mem:
    mov ah, 09h
    mov dx, msg_ok
    int 21h

    ; Exit from protected mode
    mov ax, 4C00h
    int 21h

.try_16bit:
    ; Allocate private data for DPMI host
    mov bx, [host_para]
    test bx, bx
    jz .skip_alloc16
    mov ah, 48h
    int 21h
    jc .no_mem
    mov es, ax
.skip_alloc16:

    ; Switch to 16-bit protected mode
    mov ax, 0           ; 0 = 16-bit client
    call far [entry_off]
    jc .pm_fail16

    mov ah, 09h
    mov dx, msg_pm16
    int 21h

    mov ax, 4C00h
    int 21h

.pm_fail32:
    mov ah, 09h
    mov dx, msg_pmfail32
    int 21h
    mov ax, 4C01h
    int 21h

.pm_fail16:
    mov ah, 09h
    mov dx, msg_pmfail16
    int 21h
    mov ax, 4C01h
    int 21h

.no_dpmi:
    mov ah, 09h
    mov dx, msg_nodpmi
    int 21h
    mov ax, 4C01h
    int 21h

.no_mem:
    mov ah, 09h
    mov dx, msg_nomem
    int 21h
    mov ax, 4C01h
    int 21h

; Print EAX as unsigned decimal
print_dec:
    push ebx
    push ecx
    push edx
    mov ecx, 0
    mov ebx, 10
.div_loop:
    xor edx, edx
    div ebx
    push edx
    inc ecx
    test eax, eax
    jnz .div_loop
.print_loop:
    pop edx
    add dl, '0'
    mov ah, 02h
    int 21h
    loop .print_loop
    pop edx
    pop ecx
    pop ebx
    ret

; Data
entry_off       dw 0
entry_seg       dw 0
host_para       dw 0
dpmi_flags      dw 0
dpmi_ver_major  db 0
dpmi_ver_minor  db 0
dpmi_cpu        db 0

msg_found       db 'DPMI server detected.', 13, 10, '$'
msg_ver         db 'DPMI version: $'
msg_cpu         db ', CPU type: $'
msg_16only      db '16-bit DPMI only (no 32-bit support)', 13, 10, '$'
msg_32bit       db '32-bit DPMI supported', 13, 10, '$'
msg_pm32        db '32-bit protected mode switch OK!', 13, 10, '$'
msg_pm16        db '16-bit protected mode switch OK!', 13, 10, '$'
msg_dpmi_ver    db 'DPMI host version: $'
msg_free        db 'Free DPMI memory: $'
msg_kb          db ' KB', 13, 10, '$'
msg_crlf        db 13, 10, '$'
msg_ok          db 'All DPMI tests passed!', 13, 10, '$'
msg_nodpmi      db 'No DPMI server found.', 13, 10, '$'
msg_nomem       db 'Memory allocation failed.', 13, 10, '$'
msg_pmfail32    db '32-bit protected mode switch FAILED!', 13, 10, '$'
msg_pmfail16    db '16-bit protected mode switch FAILED!', 13, 10, '$'

align 4
meminfo:    times 48 db 0   ; DPMI memory info structure (12 dwords)
