.model small 
.stack 256

.data
shiftFlag dw 0
procedgere db 'MYPROGRAM$'
space db '!$'
enterShift db 'Enter shit$'
indent  db '', 0Dh, 0Ah, '$'
shiftValue db 13
transferValue db 0
enterShiftttt db 'Enter shift:$'
alphabet db 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'
zSymb db 'z$'
cnt dw 0

Symbol label byte  
maxlenSymbol db 11
actlenSymbol db ?       
fldSymbol db 11 dup('$')

output db 100 dup('$')

parM label byte  
maxlenM db 4    
actlenM db ?        
fldM db 4 dup('$')  

.code

UintToStr proc     ; данная функция переводит шестнадцатеричное беззнаковое число в десятичную строку
push ax            ; сохраняем значение нашего числа в стек
push cx            ; сохраняем значение нашего числа в стек
push dx            ; сохраняем значение нашего числа в стек
push bx            ; сохраняем значение нашего числа в стек
push di

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

pop di
pop bx
pop dx
pop cx
pop ax
ret
UintToStr endp

SIntToStr proc 
push ax ; сохраняем наше число
push di

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

pop di
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

shift proc far 
    push ax
    push bx
    xor ax,ax
    mov al , [si]   ; засовываю символ в регистр

    push di
    push ax
    push cx
    push bx
    mov cx , 36
    mov bx,0
    @ALPA:
    lea di, [alphabet + bx]
    inc bx
    cmp al , [di]
    jz @bb
    loop @ALPA
    pop bx
    pop cx
    pop ax
    pop di
    

    @vseStrochie:
    xor ax,ax
    mov al , [si]   ; засовываю символ в регистр

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; тут будет происходить сдвиг;
    cmp shiftValue,0
    jl @minus
    add al , shiftValue         ; для положительного смещения
    cmp al , zSymb
    jb @skipTransfer
    sub al , 7Ah
    mov transferValue , al
    mov al , 61h
    sub transferValue , 1
    add al, transferValue
    jmp @skipTransfer
    @minus:
    push bx
    
    xor bx,bx
    mov bl , 'a'
    sub al , bl
    mov bl , shiftValue
    neg bl
    cmp al , bl
    jg @isGood
    mov bl , shiftValue
    add bl , al
    mov al , 'z'
    add al,bl
    add al , 1
    @isGood:
    pop bx
    jmp @skipTransfer


    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    @skipTransfer:
    mov [di],al
    
    lea dx , output
        mov ah,09
        int 21h

    inc di
    pop bx
    pop ax
    iret

    @bb:
    pop bx
    pop cx
    pop ax
    pop di
    jmp @skipTransfer
shift endp

withoutShift proc far
push ax
    xor ax,ax
    sti
    mov al , [si]   ; засовываю символ в регистр
    mov [di],al
    
    lea dx , output
        mov ah,09
        int 21h

    inc di
    pop ax
    iret
withoutShift endp

whatToDo proc near
    push si
    push di
    push cx
    push dx

        xor ax,ax
        xor dx,dx

    mov cx , 11
    mov bx , 0
    cld
    @Parse:
    mov al , [Symbol + 2 + bx]
    mov dl , [procedgere+ bx ]
    cmp al,dl
    jnz @exitpromParse   ; введённая шляпа - не команда к смене прерываний
    loop @Parse

    @makeProc:
    ; сделать ввод сдвига
    
    cmp shiftFlag , 1
    jz @OFF
    jnz @ON
    jmp @exitFunc

    @OFF:
    call shiftOFF
    jmp @exitFunc
    @ON:
        push di     
        lea dx, enterShiftttt                                ; Ввод строки   
        mov ah, 09
        int 21h
        lea dx, parM
        mov ah, 0Ah
        int 21h
        lea bx, parM+1
        push ax           
        xor ax,ax                  
        call enterNum
        mov ax , di
        mov shiftValue ,al
        pop ax
        pop di
    call shiftOn
    jmp @exitFunc

    @exitpromParse:    
    int 87h
    @exitFunc:
    pop dx
    pop cx
    pop di
    pop si
    ret
whatToDo endp

shiftOn proc near
    mov shiftFlag , 1
    push si
    push di
    push cx
    push es
    
    push 0
    pop es
    pushf
    cli
    mov es:[87h*4] , offset shift
    mov es:[87h*4+2] , seg shift
    popf

    pop es
    pop cx
    pop di
    pop si
    ret
shiftOn endp

shiftOFF proc near
    mov shiftFlag , 0
    push si
    push di
    push cx
    push es
    
    push 0
    pop es
    pushf
    cli
    mov es:[87h*4] , offset withoutShift
    mov es:[87h*4+2] , seg withoutShift
    popf

    pop es
    pop cx
    pop di
    pop si
    ret
shiftOFF endp

start:
    mov ax,@data
    mov ds,ax
        lea di , output ; не трогать, потому что в shift я итерируюсь по di 
        mov cx , 100
       
        @lp:
        call makeIntend
        lea dx, Symbol
        mov ah, 0Ah
        int 21h     
        lea si , Symbol + 2 ; вычислять после каждого ввода
        call makeIntend
        
        call whatToDo
        ;call shift
        loop @lp

        @exit:
            mov ah, 4ch
            int   21h
end start

; Лабораторная 5 Вариант 2. Реализуйте резидентную программу, которая при выполнении устанавливает обработчик, делающий циклический сдвиг строчных букв латинского алфавита на заданное число в аргументе (аргумент опциональный, если не указан, считайте сдвиг равен 13). 
;Пример:
;	Выполняем команду:
;MYPROGRAM 3
;	Выполнение завершается.
;	Далее осуществляем ввод:
;	ввод a -> на экране d
;	ввод z -> на экране dc
;	ввод X -> на экране dcX
;	ввод 1 -> на экране dcX1
;	При повторном выполнении команды обработчик должен быть снят.

; Сначала вводим MYPROGRAM 
; потом уже символы
