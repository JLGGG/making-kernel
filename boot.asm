 ORG 0
 BITS 16
_start:
    jmp short start
    nop

times 33 db 0

 start:
    jmp 0x7c0:step2

step2:
    cli ; clear interrupts
    mov ax, 0x7c0
    mov ds, ax
    mov es, ax
    mov ax, 0x00
    mov ss, ax
    mov sp, 0x7c00
    sti ; Enable interrupts

    mov ah, 2 ; READ SECTOR COMMAND
    mov al, 1 ; ONE SECTOR TO READ
    mov ch, 0 ; Cylinder low eight bits
    mov cl, 2 ; READ SECTOR TWO
    mov dh, 0 ; Head number
    mov bx, buffer
    int 0x13
    jc error

    mov si, buffer
    call print

    jmp $
error:
    mov si, error_message
    call print
    jmp $

print:
    mov bx, 0
.loop:
    lodsb
    cmp al, 0
    je .done
    call print_char
    jmp .loop
.done:
    ret

print_char:
    mov ah, 0eh
    int 0x10
    ret

error_message: db 'Failed to load sector', 0

times 510- ($ - $$) db 0
dw 0xAA55 ; boot signature

buffer:

; nasm -f bin ./boot.asm -o ./boot.bin: making bin
; ndisasm ./boot.bin: disassembly output
; qemu-system-x86_64 -hda ./boot.bin: running it on QEMU
; bless ./boot.bin: Watcing binary of the target