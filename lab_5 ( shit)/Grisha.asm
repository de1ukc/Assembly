intOn proc near
;push ax bx cx dx 
        MOV ax, 3521H                          ; получение адреса системного обработчика                         ; прерываний от клавиатуры
        INT 21H
        MOV WORD PTR oldHendler, BX
        MOV WORD PTR oldHendler + 2, ES

        MOV Ax, 2521H                          ; установка адреса нового обработчика                         ; прерываний от клавиатуры
        MOV DX, OFFSET newInt
        INT 21H

        ;mov ax, 3100h
        MOV DX, OFFSET start     ; вычисление размера резидентной части
        ;INT 31H                              ; завершение резидентной программы с
        ;int 21h
        int 27h                             ; сохранением части её кода в памяти

;pop dx cx bx ax
ret
intOn endp

CommandParse proc near
push ax bx cx dx si

    mov cx , 9
    mov bx , 0
@Parse:
    mov al , [si + bx]
    mov dl , [makeINT + bx ]
    cmp al,dl
    jnz @noCommand
    inc bx
    loop @Parse
        
        call isMyIntOn    ; вернёт ax = 1 , если сдвиг уже был внедрён в память
        mov ax , 0   ;  это для теста, потом убери сделай функцию проверки своего обработчика
        test ax,ax    ; если не ноль, то сдвиг внедрён
        jnz @turnOFF      
        
        call intOn

@noCommand:
pop si dx cx bx ax
ret
@turnOFF:
call intOFF
jmp @noCommand
CommandParse endp