.model tiny
 
.code

        org     100h
start:
        jmp     main
 
int21h_handler  proc
        pushf
        ;проверка вызываемой функции прерывания
        ;если не перехватываемая, то вызвать исходный обработчик
        cmp     ah,     09h
        jne     OrigInt
        ;действия нового обработчика функции прерывания

        push ax bx cx dx
        mov al , [si]
        cmp cx , 0
jl @minus
        add al , cl
        cmp al, 'z'
jbe @skipTransfer
        sub al , 7Ah
        mov bl , al
        mov al , 61h
        sub bl , 1
        add al , bl
jmp @skipTransfer

@minus:
        add al , cl
        cmp al , 'a'
        jl @perenos
        jmp @skipTransfer
@perenos:
        sub al , cl
        sub al , 'a'
        neg cx
        sub cl , al
        mov al , 'z'
        sub al , cl
        add al , 1

@skipTransfer:
                xor dx,dx
                mov dl , al
                mov ah , 02h
                jmp cs:dword ptr [old_int21h] ;int 21h
                pop dx cx bx ax
               
        popf
        retf    2
        ;вызов исходного обработчика прерывания
OrigInt:
        popf
        pop dx cx bx ax 
        jmp     cs:dword ptr [old_int21h]
 
        public  old_int21h
        old_int21h      dd      ?
int21h_handler  endp
 
main    proc
        ;установка обработчика прерывания
        ;- получить адрес исходного обработчика
        mov     ax,     3521h                   ; AH = 35h, AL = номер прерывания
        int     21h                             ; получить адрес обработчика
        mov     word ptr [old_int21h],   bx     ; и записать его в old_int21h
        mov     word ptr [old_int21h+2], es
        ;- записать адрес нового обработчика
        mov     ax,     2521h                   ; AH = 25h, AL = номер прерывания
        mov     dx,     offset int21h_handler
        mov     bx,     cs
        mov     ds,     bx
        int     21h

        ;завершение программы
        mov     dx,     offset main
        int     27h
 
main    endp
 
        end     start