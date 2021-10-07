.model small
.stack 512

.data 
N dw 0
result dw 0
enterN db 'Enter N: $'
indent  db '', 0Dh, 0Ah, '$'

parN label byte  ; переменная N
maxlenN db 10    ; максимальное число симолов
actlenN db ?        ; настоящая длина
fldN db 10 dup('$')     ; поле числа

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

Numbers proc
    mov cx,N
    mov bx,N
   
    @lp:
        mov ax,N
        xor bh,bh
        div bl
        cmp ah,0
        je @increment
        jne @proceed
        @increment:    
        add result,1
        @proceed:
        sub bl,1
    loop @lp
    
    cmp N,1
    je @check
    jne @skip
    @check:
    add result,2  ; для единицы всегда ответ 1, потому просто добавим 2
    @skip:
    sub result,2
    mov ax,result 
    call SIntToStr
    ret
Numbers endp

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
        mov N, di

        call Numbers
        @exit:
            mov ah, 4ch
            int   21h
end start