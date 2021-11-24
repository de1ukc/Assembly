.model small
.stack 512

.data 





. code

makeIntend proc near
    lea dx, indent
    mov ah, 09
    int 21h
    ret
makeIntend endp



start:
mov ax,@data
    mov ds,ax


@exit:
        mov ah, 4ch
        int   21h

end start