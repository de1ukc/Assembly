.model small
.stack 512

.data
a dw 0
b dw 0
c dw 0
d dw 0
result   dw   0

enterA db 'Enter a: $'
enterB db 'Enter b: $'
enterC db 'Enter c: $'
enterDD db 'Enter d: $'
indent  db '', 0Dh, 0Ah, '$'

parA label byte  ; переменная А
maxlenA db 10    ; максимальное число симолов
actlenA db ?        ; настоящая длина
fldA db 10 dup('$')     ; поле числа

parB label byte
maxlenB db 10
actlenB db ?
fldB db 10 dup('$')

parC label byte
maxlenC db 10
actlenC db ?
fldC db 10 dup('$')

parD label byte
maxlenD db 10
actlenD db ?
fldD db 10 dup('$')

.code
makeIntend proc near
    lea dx, indent
    mov ah, 09
    int 21h
    ret
makeIntend endp


UintToStr proc     ; данная функция переводит шестнадцатеричное беззнаковое число в десятичную строку
push ax            ; сохраняем значение нашего числа в стек
push cx            ; сохраняем значение нашего числа в стек
push dx            ; сохраняем значение нашего числа в стек
push bx            ; сохраняем значение нашего числа в стек

xor cx,cx               ;Обнуление счётчик для цикла
mov bx,10    ;задаём систему счисления

numbers_loop:  ; в (недо)цикле будем получать остатки от деления, т.е. соответственно , наше число
xor dx,dx ; нужна как регистровая пара DX:AX, в DX находится остаток, потому зануляем его
div bx;
push dx
inc cx   ; счётчик для последующего(второго) цикла
test ax,ax ; проверка на равенство нулю
jnz numbers_loop
mov ah, 02h

OutStr:
pop dx ; достаём один символ
add dl,'0'
int 21h
loop OutStr

pop bx
pop dx
pop cx
pop ax
ret
UintToStr endp


SIntToStr proc 
push ax ; сохраняем наше число
test ax,ax ; проверяем знак ax
jns AnsNoSigned ; даём ответ, если беззнаковое
xchg cx,ax
mov ah,02h
mov dl,'-'
int 21h
xchg cx,ax
neg ax
AnsNoSigned:
call UintToStr
pop ax
ret

SIntToStr endp

enterNum proc near
    mov di, 0           
    mov cx, [bx]                                       ;в CX количество введенных символов
    xor ch, ch
    mov si, 1                                          ;в SI множитель 

    @loopMet:
    cmp cx,1
    push si                                            ;сохраняем SI (множитель) в стеке
    mov si, cx                                         ;в SI помещаем номер текущего символа 
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
    pop si
    call makeIntend
    ret
    @Signed:
    push dx
    mov dx,[bx+si]
    xor dh,dh
    cmp dl,'-'
    jne @NoSigned
    pop dx
    pop si
    neg di
    jmp @return
enterNum endp

main:
    mov ax,@data
    mov ds,ax
    
        xor ax,ax
        xor dx,dx
        lea dx, enterA                                  ;вводим а   
        mov ah, 09
        int 21h
        lea dx, parA
        mov ah, 0Ah
        int 21h
        lea bx, parA+1                                  ;в BX адрес второго элемента буфера
        call enterNum
        mov a, di

        xor dx,dx
        lea dx, enterB                                 ;вводим а   
        mov ah, 09
        int 21h
        lea dx, parB
        mov ah, 0Ah
        int 21h
        lea bx, parB+1                                  ;в BX адрес второго элемента буфера
        call enterNum
        mov b, di

        xor dx,dx
        lea dx, enterC                                 ;вводим а   
        mov ah, 09
        int 21h
        lea dx, parC
        mov ah, 0Ah
        int 21h
        lea bx, parC+1                                  ;в BX адрес второго элемента буфера
        call enterNum
        mov c, di

        xor dx,dx
        lea dx, enterDD                                  
        mov ah, 09
        int 21h
        lea dx, parD
        mov ah, 0Ah
        int 21h
        lea bx, parD+1                                  
        call enterNum
        mov d, di

    
    mov bx,b
    mov cx,c

    cmp bx,cx ; проверяю (b < c)
    jl @FirstAns
    jge @FirstCondition

        @FirstCondition:                        ;  ((b * с) != (d - a))
            mov ax,bx
            imul cx
            mov dx,d
            mov cx,a
            sub dx,cx
            cmp ax,dx
            jne @FirstAns
            je @SecondCondition

                @FirstAns:                      ;  (3 * a + b * (c - d))
                   mov dx,d
                   mov cx,c
                   mov bx,b
                   sub cx,dx
                   mov ax,cx
                   mul bx
                   mov bx,ax
                   mov ax,a
                   add ax,a
                   add ax,a
                   add ax,bx
                   call SIntToStr
                   jmp @exit

        @SecondCondition:                       ; (a < b)
            mov ax,a
            mov bx,b
            cmp ax,bx
            jl @LowSecCondit
            jge @ThirdAns
        
                @LowSecCondit:                  ;((a - d) < (b + c))
                    mov dx,d
                    mov cx,c
                    sub ax,dx
                    add bx,cx
                    cmp ax,bx
                    jl @SecondAns
                    jge @ThirdAns

                        @SecondAns:             ; (a * a - b + c) 
                            mov ax,a
                            mov bx,b
                            mov cx,c
                            mul ax
                            add ax,cx
                            sub ax,bx
                            mov result,ax
                            jmp @exit

                        @ThirdAns:              ; (2 * b - 5 * d + 3)
                            mov bx,b
                            mov ax,d
                            mov si,5
                            mul si
                            mov dx,ax
                            add bx,bx
                            add bx,3
                            sub bx,dx
                            mov result,bx
                            jmp @exit
    
    @exit:
        mov ax,result
        call SIntToStr
        mov ah, 4ch
        int   21h
end main
;if ((b * с) != (d - a)) or (b < c):        
;    print(3 * a + b * (c - d))       FIRST ANS
;else:
;    if ((a - d) < (b + c)) and (a < b):
;        print(a * a - b + c)               SECOND ANS
;    else:
;        print(2 * b - 5 * d + 3)           THIRD ANS
