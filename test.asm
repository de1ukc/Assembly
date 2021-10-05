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