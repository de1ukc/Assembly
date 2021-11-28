.model small
.stack 16384	

.data 
n dw 0
m dw 0

enterN db 'Enter n: $'
enterM db 'Enter m: $'
indent  db '', 0Dh, 0Ah, '$'





; НИЖЕ - ДЛЯ ВВОДА

parN label byte  ; переменная n
maxlenN db 4    ; максимальное число симолов
actlenN db ?        ; настоящая длина
fldN db 4 dup('$')     ; поле числа

parM label byte  ; переменная m
maxlenM db 4    ; максимальное число симолов
actlenM db ?        ; настоящая длина
fldM db 4 dup('$')     ; поле числа


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
          
        lea dx, enterN                                 ;вводим а   
        mov ah, 09
        int 21h
        lea dx, parN
        mov ah, 0Ah
        int 21h
        lea bx, parN+1                                  ;в BX адрес второго элемента буфера
        call enterNum
        mov n , di
          
        lea dx, enterM                                  ;вводим а   
        mov ah, 09
        int 21h
        lea dx, parM
        mov ah, 0Ah
        int 21h
        lea bx, parM+1                                  ;в BX адрес второго элемента буфера
        call enterNum
        mov m , di


        @exit:
            mov ah, 4ch
            int   21h
end start





















; Лабораторная 4 . Вариант 4
; Необходимо определить минимальное значение для каждой строки и каждого столбца матрицы. В качестве результата вычислите сумму полученных значений.