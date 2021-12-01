.model small
.stack 16384	

.data 
n dw 0
m dw 0
actLen dw 0
buffLen dw 0

enterN db 'Enter n: $'
enterM db 'Enter m: $'
indent  db '', 0Dh, 0Ah, '$'
space db ' $'
symb db '!'
end db '$'

matrix db 10000 dup('$')

help1 dw 0
help2 dw 0



; НИЖЕ - ДЛЯ ВВОДА

parN label byte  
maxlenN db 4    
actlenN db ?       
fldN db 4 dup('$')     

parM label byte  
maxlenM db 4    
actlenM db ?        
fldM db 4 dup('$')     

Raw label byte  
maxlenRaw dw 401 
actlenRaw dw ?        
fldRaw db 401 dup('$')

Buffer label byte  
maxlenBuffer db 5
actlenBuffer db ?       
fldBuffer db 5 dup('$')

buffer2 db 6 dup('$')

.code 

searchSize proc near     ; Ищем размер введённой строки
        push cx   
        mov cx, [bx] 
        xor ch, ch
        mov actLen,cx
        pop cx
        ret
searchSize endp


searchSizeBuff proc near     ; Ищем размер введённой строки
        push cx   
        mov cx, [bx] 
        xor ch, ch
        mov actlenBuffer,cl
        pop cx
        ret
searchSizeBuff endp

makeIntend proc near
    lea dx, indent
    mov ah, 09
    int 21h
    ret
makeIntend endp

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

enterNum1 proc near
    mov di, 0           
    mov cx, buffLen                                    ;в CX количество введенных символов
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
enterNum1 endp

help proc near
    push ds    
    pop es

    lea di , Raw + 2
    lea bx , Raw + 1
    call searchSize      
    mov cx, actLen            ; нашёл количество символов введённой строки

    @SymbolsLoop:
    lea si,space          ; каждый раз помещаю в источник разделитель
    cmpsb
    ;je @ToMatrix
    jne @ToBuffer

    @NextIteration:
    loop @SymbolsLoop
    jmp @bb

    @ToBuffer:
    inc help1
    push di
    push cx
    push ax
    xor ax,ax
    xor cx,cx      

                

    dec di
    mov al , [di]    ; засунул символ в регистр
    inc di
    xor di,di

    lea di , [buffer2]
    mov cx , help1
    sub cx , 1
    test cx,cx
    jz @skip1
    @lp1:
    inc di
    loop @lp1
    @skip1:
    stosb    
                                    lea si, buffer2        
                        lea di, Buffer 		   
                        mov cx, 5          
                        cld                  
                        rep movsb   
                        mov cl , actlenBuffer

                        xor bx,bx
                        lea bx , buffer + 1
                        call searchSizeBuff
                        mov cl , actlenBuffer

                        lea dx, buffer
                        mov ah, 09 
                        int 21h

                        lea dx, symb
                         mov ah, 09
                        int 21h
    pop ax
    pop cx
    pop di

    jmp @NextIteration

    @ToMatrix:       ; неверно работает 
    inc help2


    push cx
    push di
    push ax
    push si
    
    xor ax,ax
    xor si,si

    

    lea bx , Buffer + 1
    call enterNum
    mov al , [di]
    lea di , matrix

    stosb

    lea   di, Buffer
    mov   cx, 5
    mov   al,'$'           ;пробел
    rep   stosb            ;отправляем СХ-пробелов по адресу ES:DI
    pop cx
    pop di

    pop si
    pop ax
    pop di
    pop cx
    jmp @NextIteration
    
    @bb:
    ret
help endp

start:
    mov ax,@data
    mov ds,ax

        lea dx, Raw
        mov ah, 0Ah
        int 21h

        call makeIntend

        call help

       ; lea dx , matrix
       ; mov ah, 09
       ; int 21h

        jmp @exit
        

        lea dx, enterN                                 ;вводим а   
        mov ah, 09
        int 21h
        lea dx, parN
        mov ah, 0Ah
        int 21h
        lea bx, parN+1                                  ;в BX адрес второго элемента буфера
        call enterNum
        call makeIntend
        mov n , di
          
        lea dx, enterM                                  ;вводим а   
        mov ah, 09
        int 21h
        lea dx, parM
        mov ah, 0Ah
        int 21h
        lea bx, parM+1                                  ;в BX адрес второго элемента буфера
        call enterNum
        call makeIntend
        mov m , di

        
        
        
        ;call help

        ;lea dx, buffer                                 
        ;mov ah, 09
        ;int 21h

        ;call makeIntend

       ; lea dx, matrix                                  ; проверяем матрицу  
        ;mov ah, 09
       ; int 21h


        @exit:
            mov ah, 4ch
            int   21h
end start


;lea di , wtf
;mov al , [di + 1 ]  ; получаю именно одну букву из строки, т.е. один символ
; сравнивать посимвольно, пока не нашёл, заносить в di , когда нашёл, переводить это в число и заносить в массив
; двумя цепочечными командами

; Лабораторная 4 . Вариант 4
; Необходимо определить минимальное значение для каждой строки и каждого столбца матрицы. В качестве результата вычислите сумму полученных значений.
