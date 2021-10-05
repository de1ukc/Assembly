.model small
.stack 512

.data
a dw 135
answer db ''


.code

print_str proc
    push ax
    mov ah,9                ;Функция DOS 09h - вывод строки
    xchg dx,di              ;Обмен значениями DX и DI
    int 21h                 ;Обращение к функции DOS
    xchg dx,di              ;Обмен значениями DX и DI
    pop ax
    ret
print_str endp

UintToStr proc     ; данная функция переводит шестнадцатеричное беззнаковое число в десятичную строку
push ax ; сохраняем значение нашего числа в стек
push cx
push dx
push bx ;
xor cx,cx               ;Обнуление счётчик для цикла
mov bx,10    ;задаём систему счисления

numbers_loop:  ; в (недо)цикле будем получать остатки от деления, т.е. соответственно , наше число
xor dx,dx ; нужна как регистровая пара DX:AX, в DX находится остаток, потому зануляем его
div bx;
add dl,'0'
push dx
inc cx   ; счётчик для последующего(второго) цикла
test ax,ax ; проверка на равенство нулю
jnz numbers_loop

OutStr:
pop dx ; достаём один символ
mov [di],dl ; сохраняем сразу в строку
inc di ; итерируюсь по строке
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
mov byte ptr [di] , '-'
inc di
neg ax

AnsNoSigned:
call UintToStr
pop ax
ret

SIntToStr endp

main:
mov ax,@data
mov ds,ax
mov ax,a

call SIntToStr
call print_str
;mov dx , offset answer
;mov ah,9
;int 21h

@exit:
        mov ah, 4ch
        int   21h
end main







Вроде, работает для любых значений код снизу






.model small
.stack 512

.data 
a dw 0
b dw 0
c dw 0
d dw 0

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
    mov ax,a
    call SIntToStr



        @exit:
            mov ah, 4ch
            int   21h
end start
