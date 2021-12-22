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
        cld 


        mov shiftValue, dh

        push ax 
        push bx
        push cx
        push dx

        mov ax , si
        cmp shiftValue , 0
jl @minus
        add al , shiftValue
        cmp al, 'z'
jbe @skipTransfer
        sub al , 7Ah
        mov bl , al
        mov al , 61h
        sub bl , 1
        add al , bl
jmp @skipTransfer
 
@minus:
        add al , shiftValue
        cmp al , 'a'
        jl @perenos
        jmp @skipTransfer
@perenos:
        sub al , shiftValue
        sub al , 'a'
        neg shiftValue
        sub shiftValue , al
        mov al , 'z'
        sub al , shiftValue
        add al , 1
 
@skipTransfer:
        xor dx,dx
        mov dl , al
        mov ah , 02h
        int 21h
        pop dx
        pop cx
        pop bx
        pop ax
        popf
        retf 4
        
OrigInt:
        popf
        jmp     cs:dword ptr [old_int21h]
 
        public  old_int21h
        old_int21h      dd      ?

        shiftValue db ?
        
int21h_handler  endp

enterNum proc near
    mov di, 0           
    mov cx, [bx]                                       ;в CX количество введенных символов
    xor ch, ch
    mov si, 1                                          ;в SI множитель 

    @loopMet:
    push si                                            ;сохраняем SI (множитель) в стеке
    mov si, cx                                         ;в SI помещаем номер текущего символа 
    cmp cx,1
    je @Signed
    @NoSigned:
    mov ax, [bx+si]                                    ;в AX помещаем текущий символ 
    xor ah, ah
    pop si                                             ;извлекаем множитель (SI) из стека
    sub ax, 30h                                        ;получаем из символа (AX) цифру
    mul si                                             ;умножаем цифру (AX) на множитель (SI)
    add di, ax                                         ;складываем с результирующим числом
    mov ax, si                                         ;помещаем множитель (SI) в AX
    mov dx, 10
    mul dx                                             ;увеличиваем множитель (AX) в 10 раз
    mov si, ax                                         ;перемещаем множитель (AX) назад в SI
    loop @loopMet                                      ;переходим к предыдущему символу
    @return:
    ret
    @Signed:
    push dx
    mov dx,[bx+si]
    xor dh,dh
    cmp dl,'-'
    pop dx
    jne @NoSigned
    neg di
    pop si
    jmp @return
enterNum endp
 
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
        msgPressAnyKey  db      0Dh, 0Ah, 'Press any key to exit...', '$'

                parM label byte  
        maxlenM db 4    
        actlenM db ?        
        fldM db 4 dup('$')  

main    endp
 
        end     start