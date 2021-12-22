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
        push    si
        push    dx
        ;посимвольно просматривается строка
        mov     si,     dx
        cld
        jmp     @@next
        @@repeat:
                ;для символов латинского алфавита
                cmp     al,     'A'
                jb      @@ShowChar
                cmp     al,     'Z'
                jbe     @@ChangeRegister
                cmp     al,     'a'
                jb      @@ShowChar
                cmp     al,     'z'
                jbe     @@ChangeRegister
 
                jmp     @@ShowChar
        @@ChangeRegister:
                ;изменение регистра
                xor     al,     ('A' xor 'a')
        @@ShowChar:
                ;вывод символа
                mov     ah,     02h
                mov     dl,     al
                int     21h
        @@next:
                ;очередной символ строки
                lodsb
                ;проверяется на равенство символу '$' (завершение строки)
                cmp     al,     '$'
        jne     @@repeat
 
        pop     dx
        pop     si
 
        popf
        retf    2
        ;вызов исходного обработчика прерывания
OrigInt:
        popf
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
 
        ;ожидание нажатия любой клавиши
        mov     ah,     09h
        lea     dx,     [msgPressAnyKey]
        ;int     21h
        pushf
        call    cs:dword ptr [old_int21h]
 
        mov     ah,     00h
        int     16h
 
        ;завершение программы
        mov     dx,     offset main
        int     27h
 
        msgPressAnyKey  db      0Dh, 0Ah, 'Press any key to exit...', '$'
main    endp
 
        end     start