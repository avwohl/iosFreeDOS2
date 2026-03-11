; R.COM - Read file from host into DOS file
; Usage: R <hostpath> <dosfile>
;
; Uses INT E0h for host file operations:
;   AH=01: Open host file for reading, DS:DX -> ASCIIZ path
;   AH=03: Read one byte -> AL, CF=1 on EOF
;   AH=05: Close file, AL=0 for read side

org 100h

start:
    ; Parse command line (PSP:80h = length, PSP:81h = tail)
    mov si, 81h
    mov cl, [80h]
    xor ch, ch

    call skip_spaces
    or cx, cx
    jz near usage_err

    ; Copy first arg (host path)
    mov di, host_path
    call copy_arg

    call skip_spaces
    or cx, cx
    jz near usage_err

    ; Copy second arg (DOS file path)
    mov di, dos_path
    call copy_arg

    ; Open host file for reading
    mov ah, 01h
    mov dx, host_path
    int 0E0h
    jc near err_host_open

    ; Create DOS file
    mov ah, 3Ch
    xor cx, cx
    mov dx, dos_path
    int 21h
    jc near err_dos_create
    mov [handle], ax

    ; Copy loop: host -> DOS
.copy:
    mov ah, 03h
    int 0E0h
    jc .done

    mov [buf], al
    mov ah, 40h
    mov bx, [handle]
    mov cx, 1
    mov dx, buf
    int 21h
    jc near err_write

    jmp .copy

.done:
    ; Close host file
    mov ah, 05h
    mov al, 0
    int 0E0h

    ; Close DOS file
    mov ah, 3Eh
    mov bx, [handle]
    int 21h

    mov ah, 09h
    mov dx, msg_ok
    int 21h

    mov ax, 4C00h
    int 21h

;------ Subroutines ------

skip_spaces:
    jcxz .done
.loop:
    lodsb
    dec cx
    cmp al, ' '
    je .loop
    cmp al, 09h
    je .loop
    dec si
    inc cx
.done:
    ret

copy_arg:
.loop:
    jcxz .end
    lodsb
    dec cx
    cmp al, ' '
    je .end
    cmp al, 09h
    je .end
    cmp al, 0Dh
    je .end
    stosb
    jmp .loop
.end:
    mov byte [di], 0
    ret

;------ Error handlers ------

usage_err:
    mov dx, msg_usage
    jmp short print_err

err_host_open:
    mov dx, msg_host_err
    jmp short print_err

err_dos_create:
    mov ah, 05h
    mov al, 0
    int 0E0h
    mov dx, msg_dos_err
    jmp short print_err

err_write:
    mov ah, 05h
    mov al, 0
    int 0E0h
    mov ah, 3Eh
    mov bx, [handle]
    int 21h
    mov dx, msg_write_err

print_err:
    mov ah, 09h
    int 21h
    mov ax, 4C01h
    int 21h

;------ Data ------

msg_usage:     db 'Usage: R <hostfile> <dosfile>',0Dh,0Ah,'$'
msg_ok:        db 'File transferred.',0Dh,0Ah,'$'
msg_host_err:  db 'Cannot open host file.',0Dh,0Ah,'$'
msg_dos_err:   db 'Cannot create DOS file.',0Dh,0Ah,'$'
msg_write_err: db 'Write error.',0Dh,0Ah,'$'

handle:  dw 0
buf:     db 0
host_path: times 128 db 0
dos_path:  times 128 db 0
