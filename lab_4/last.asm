.model small
.stack 16384	

.data 
n dw 0
m dw 0
i dw 0
j dw 0
sum dw 0
colomsVal dw 0
cnt dw 0

enterN db 'Enter n: $'
enterM db 'Enter m: $'
enterNumber db 'Enter number: $'
indent  db '', 0Dh, 0Ah, '$'




matrix dw 10000 dup(0)

; НИЖЕ - ДЛЯ ВВОДА

parN label byte  
maxlenN db 4    
actlenN db ?       
fldN db 4 dup('$')     

parM label byte  
maxlenM db 4    
actlenM db ?        
fldM db 4 dup('$')     

Buffer label byte  
maxlenBuffer db 5
actlenBuffer db ?       
fldBuffer db 5 dup('$')


.code 

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

raws proc near
    push ax
    push bx
    push cx
    push di

    xor ax,ax
    xor bx,bx
    xor cx,cx
    xor di,di

        mov cx,m
        lea di , matrix
    @lp2:
        xor ax,ax
        xor bx,bx
        xor di,di
        
        
        push cx
        lea dx, enterNumber                                  
        mov ah, 09
        int 21h
        lea dx, Buffer
        mov ah, 0Ah
        int 21h
        lea bx, Buffer+1                                  ;в BX адрес второго элемента буфера
        push di
        call enterNum
        mov ax , di
        pop di

        mov bx , i
        mov matrix[bx],ax
        inc i
        inc i
        inc i
        inc i
        call makeIntend
        pop cx

    loop @lp2

    pop di
    pop cx
    pop bx
    pop ax
    ret
raws endp

Raw proc
    push ax
    push bx
    push cx
    push di

    xor ax,ax
    xor bx,bx
    xor cx,cx
    xor di,di

    mov bx, j
    mov ax , matrix[bx]
    mov cx , m
    @lpTask:   
    mov bx, j
    mov dx , matrix[bx]
    cmp dx,ax
    jl @swap
    jge @lolSkip
    
    @swap:
    xchg ax,dx
    @lolSkip:
    inc j
    inc j
    inc j
    inc j
    loop @lpTask
    add sum , ax


    pop di
    pop cx
    pop bx
    pop ax
    ret
Raw endp

coloms proc near
    push ax
    push bx
    push cx
    push di
    inc cnt

    xor ax,ax
    xor bx,bx
    xor cx,cx
    xor di,di

    mov colomsVal,0
    mov bx, colomsVal
    mov cx, cnt
    sub cx, 1
    test cx,cx
    jz @skipPlus
    @stpdloop:
    add bx,4
    add colomsVal , 4
    loop @stpdloop
    @skipPlus:

    mov ax , matrix[bx]
    mov cx , n
    @lpTask2:   
    mov bx, colomsVal
    mov dx , matrix[bx]
    cmp dx,ax
    jl @swap2
    jge @lolSkip2
    
    @swap2:
    xchg ax,dx
    @lolSkip2:
    inc colomsVal
    inc colomsVal
    inc colomsVal
    inc colomsVal
    inc colomsVal
    inc colomsVal
    inc colomsVal
    inc colomsVal
    inc colomsVal
    inc colomsVal
    inc colomsVal
    inc colomsVal
    loop @lpTask2
    add sum , ax

    pop di
    pop cx
    pop bx
    pop ax
    ret
coloms endp

ans proc near
    push ax
    push bx
    push cx
    push di

    mov cx , n
    @byRaws:
    call Raw
    loop @byRaws

    mov cx , m
    @byColoms:
    call coloms
    loop @byColoms

    pop di
    pop cx
    pop bx
    pop ax
    ret
ans endp

help proc near
    push ax
    push bx
    push cx
    push di

    xor ax,ax
    xor bx,bx
    xor cx,cx
    xor di,di

    mov cx,n

    @lp1:
    call raws
    loop @lp1

    pop di
    pop cx
    pop bx
    pop ax
    ret
help endp

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

        call help

        call ans

        mov ax,sum
        call SIntToStr


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
