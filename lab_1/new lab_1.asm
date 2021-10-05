.model small
.stack 512

.data 
a dw 0
b dw 0
c dw 0
d dw 0
bufferD dw 0
constant2 dw 2
constant3 dw 3
constant5 dw 5

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
    call makeIntend
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

start:
    mov ax,@data
    mov ds,ax
           
        lea dx, enterA                                  ;вводим а   
        mov ah, 09
        int 21h
        lea dx, parA
        mov ah, 0Ah
        int 21h
        lea bx, parA+1                                  ;в BX адрес второго элемента буфера
        call enterNum
        mov a, di
        
        lea dx, enterB                                
        mov ah, 09
        int 21h
        lea dx, parB
        mov ah, 0Ah
        int 21h
        lea bx, parB+1                                  
        call enterNum
        mov b, di

        lea dx, enterC                               
        mov ah, 09
        int 21h
        lea dx, parC
        mov ah, 0Ah
        int 21h
        lea bx, parC+1                                  
        call enterNum
        mov c, di

        lea dx, enterDD                                
        mov ah, 09
        int 21h
        lea dx, parD
        mov ah, 0Ah
        int 21h
        lea bx, parD+1                                  
        call enterNum
        mov d, di

            ; пошёл основной код
            mov bx,b
            mov cx,c
            cmp bx,cx         ;(b < c)
            jl @FirstAnswer
            jmp @FirstCondition

                        @FirstAnswer:   ;print(3 * a + b * (c - d))
                            mov dx,d
                            mov cx,c
                            sub cx,dx
                            mov bx,b
                            xchg ax,cx
                            mul bx
                            xchg ax,cx
                            mov ax,a
                            mul constant3
                            add ax,cx
                            call SIntToStr
                            jmp @exit

                @FirstCondition:     ;((b * с) != (d - a)) аккуратно, потому что после b * с регистр eax расширится до пары DX:AX
                    mov ax,a
                    mov bx,b
                    mov cx,c
                    mov dx,d
                    sub dx,ax
                    xchg dx,bufferD
                    mov ax,bx
                    mul cx
                    cmp ax,bufferD
                    jne @FirstAnswer
                    je @SecondCondition
                
                @SecondCondition:     ; (a < b)
                mov ax,a
                mov bx,b
                cmp ax,bx
                jl @ThirdCondition
                jge @ThirdAnswer

                @ThirdCondition:    ;((a - d) < (b + c))
                    mov dx,d
                    mov cx,c
                    sub ax,dx
                    add bx,cx
                    cmp ax,bx
                    jl @SecondAnswer
                    jge @ThirdAnswer

                        @SecondAnswer: ; print(a * a - b + c)
                        mov ax,a
                        mov bx,b
                        mov cx,c
                        mul a
                        add ax,cx
                        sub ax,bx
                        call SIntToStr
                        jmp @exit

                        @ThirdAnswer:    ; print(2 * b - 5 * d + 3)
                            mov bx,b
                            mov dx,d
                            xchg dx,bufferD
                            mov ax,bx
                            mul constant2
                            xchg ax,bufferD
                            mul constant5
                            xchg ax,bufferD
                            add ax,3
                            sub ax,bufferD
                            call SIntToStr
                            jmp @exit

        @exit:
            mov ah, 4ch
            int   21h
end start


;if ((b * с) != (d - a)) or (b < c):
;    print(3 * a + b * (c - d))
;else:
;    if ((a - d) < (b + c)) and (a < b):
;       print(a * a - b + c)
;   else:
;       print(2 * b - 5 * d + 3)
; При работе с регистрами AX DX требуется быть очень внимательными , так как применяя функции mul,div , регистр AX может с лёгкостью
; превратиться в регистровую пару AX:DX => всё, что будет в DX затрётся
; в случае умножения туда пойдут нули, в сучае деления в dl пойдёт остаток!!!!!!