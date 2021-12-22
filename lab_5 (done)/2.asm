.model tiny
 
.code
        org 100h
 
main    proc

           

                push ax 
                push bx
                push dx
                push si
                        
                        lea dx, parM
                        
                        mov ah, 0Ah
                        int 21h
                        xor bx,bx
                        lea bx, parM+1
                        
                        call enterNum
                        xor ax,ax
                        mov ax , di
                        mov cx , ax   
                pop si 
                pop dx  
                pop bx 
                pop ax

                mov dl , 10
                mov ah , 02h
                int 21H
                mov dl,13
                mov ah , 02h
                int 21H

                xor dx,dx
        mov ah , 01h    
        int 21H  

        xor ah,ah
        mov si , ax
        mov     ah,     09h
       ; mov cx , 3
        int     21h
       
        int     20h



        parM label byte  
        maxlenM db 4    
        actlenM db ?        
        fldM db 4 dup('$')  

        indent  db ' ', 0Dh, 0Ah, '$'

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
        
makeIntend proc near
    lea dx, indent
    mov ah, 09
    int 21h
    ret
makeIntend endp



main    endp
 
        end     main