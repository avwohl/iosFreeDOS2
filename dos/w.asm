; W.COM - Write DOS file to host
; Usage: W <dosfile> <hostpath>
;
; Uses INT E0h for host file operations:
;   AH=02: Open host file for writing, DS:DX -> ASCIIZ path
;   AH=04: Write one byte, DL=byte
;   AH=05: Close file, AL=1 for write side

org 100h

start:
    ; Parse command line (PSP:80h = length, PSP:81h = tail)
    mov si, 81h
    mov cl, [80h]
    xor ch, ch

    call skip_spaces
    or cx, cx
    jz near usage_err

    ; Copy first arg (DOS file path)
    mov di, dos_path
    call copy_arg

    call skip_spaces
    or cx, cx
    jz near usage_err

    ; Copy second arg (host path)
    mov di, host_path
    call copy_arg

    ; Open DOS file for reading
    mov ah, 3Dh
    mov al, 0
    mov dx, dos_path
    int 21h
    jc near err_dos_open
    mov [handle], ax

    ; Open host file for writing
    mov ah, 02h
    mov dx, host_path
    int 0E0h
    jc near err_host_open

    ; Copy loop: DOS -> host
.copy:
    mov ah, 3Fh
    mov bx, [handle]
    mov cx, 1
    mov dx, buf
    int 21h
    jc .done
    cmp ax, 0
    je .done

    mov ah, 04h
    mov dl, [buf]
    int 0E0h

    jmp .copy

.done:
    ; Close DOS file
    mov ah, 3Eh
    mov bx, [handle]
    int 21h

    ; Close host file
    mov ah, 05h
    mov al, 1
    int 0E0h

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

err_dos_open:
    mov dx, msg_dos_err
    jmp short print_err

err_host_open:
    mov ah, 3Eh
    mov bx, [handle]
    int 21h
    mov dx, msg_host_err

print_err:
    mov ah, 09h
    int 21h
    mov ax, 4C01h
    int 21h

;------ Data ------

msg_usage:     db 'Usage: W <dosfile> <hostfile>',0Dh,0Ah,'$'
msg_ok:        db 'File transferred.',0Dh,0Ah,'$'
msg_dos_err:   db 'Cannot open DOS file.',0Dh,0Ah,'$'
msg_host_err:  db 'Cannot open host file.',0Dh,0Ah,'$'

handle:  dw 0
buf:     db 0
dos_path:  times 128 db 0
host_path: times 128 db 0
