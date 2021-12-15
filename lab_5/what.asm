.model tiny

.stack 256

.data

Symbol label byte  
maxlenSymbol db 11
actlenSymbol db ?       
fldSymbol db 11 dup('$')

parM label byte  
maxlenM db 4    
actlenM db ?        
fldM db 4 dup('$')  

makeINT db 'MYPROGRAM$'
alphabet db 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'

.code
start:
jmp main

CommandParse proc near
push ax 
push bx 
push cx 
push dx 
push si

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
pop si 
pop dx 
pop cx 
pop bx 
pop ax
ret
@turnOFF:
call intOFF
jmp @noCommand
CommandParse endp

intOn proc near
;установка обработчика прерывания
        ;- получить адрес исходного обработчика
        mov     ax,     3521h                   ; AH = 35h, AL = номер прерывания
        int     21h                             ; получить адрес обработчика
        mov     word ptr [old_int21h],   bx     ; и записать его в old_int21h
        mov     word ptr [old_int21h+2], es
        ;- записать адрес нового обработчика
        mov     ax,     2521h                   ; AH = 25h, AL = номер прерывания
        mov     dx,     offset int21h_handler
        mov     bx,     cs
        mov     ds,     bx
        int     21h

        ;завершение программы
        mov     dx,     offset main
        int     27h
intOn endp

intOFF proc near

intOFF endp

isMyIntOn proc near
push ax 
push bx 
push cx 
push dx 
push si

        

pop si 
pop dx 
pop cx 
pop bx 
pop ax
ret
isMyIntOn endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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

org     100h
oldHendler DD ?

toMemory:
int21h_handler  proc
        pushf
        ;проверка вызываемой функции прерывания
        ;если не перехватываемая, то вызвать исходный обработчик
        cmp     ah,     09h
        jne     OrigInt
        cld 


        mov shiftValue, dh

        push ax 
        push bx
        push cx
        push dx

        mov ax , si
        cmp shiftValue , 0
jl @minus
        add al , shiftValue
        cmp al, 'z'
jbe @skipTransfer
        sub al , 7Ah
        mov bl , al
        mov al , 61h
        sub bl , 1
        add al , bl
jmp @skipTransfer
 
@minus:
        add al , shiftValue
        cmp al , 'a'
        jl @perenos
        jmp @skipTransfer
@perenos:
        sub al , shiftValue
        sub al , 'a'
        neg shiftValue
        sub shiftValue , al
        mov al , 'z'
        sub al , shiftValue
        add al , 1
 
@skipTransfer:
        xor dx,dx
        mov dl , al
        mov ah , 02h
        int 21h
        pop dx
        pop cx
        pop bx
        pop ax
        popf
        retf 4
        
OrigInt:
        popf
        jmp     cs:dword ptr [old_int21h]
 
        public  old_int21h
        old_int21h      dd      ?

        shiftValue db ?
        
int21h_handler  endp
endToMemory label byte

makeIntend proc near
                mov dl , 10
                mov ah , 02h
                int 21H
                mov dl,13
                mov ah , 02h
                int 21H
                ret
makeIntend endp

UPPERorNUMBER proc near
push ax 
push bx 
push cx 
push dx 
push si
    mov al , [si]
    mov cx , 36
    mov bx,0
    @ALPA:
    lea di, [alphabet + bx]
    inc bx
    cmp al , [di]
    jz @govnoInFunc
    loop @ALPA
pop si 
pop dx 
pop cx 
pop bx 
pop ax
ret
@bb2:
pop si 
pop dx 
pop cx 
pop bx 
pop ax
jmp lp
@govnoInFunc:
        mov dx , [si]
        mov ah , 02
        int 21h
        jmp @bb2
UPPERorNUMBER endp

main:
         ;mov ax,@data
         ;mov ds,ax
         mov cx , 100
lp:
        call makeIntend

        lea dx, Symbol
        mov ah, 0Ah
        int 21h     
        lea si , Symbol + 2 ; вычислять после каждого ввода
        
        call makeIntend
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        
        call CommandParse

        call UPPERorNUMBER
push cx
@EnterShift:
        push ax 
        push bx 
        push dx  
        push di
        push si
        
        lea dx, parM
        mov ah, 0Ah
        int 21h
        xor bx,bx
        lea bx, parM+1
        
        call enterNum
        mov ax , di
        mov cx , ax   
        pop si 
        pop di 
        pop dx 
        pop bx  
        pop ax
        call makeIntend

@EnterEnd:    
        lea dx , Symbol + 2
        mov ah,09h
        int 21h
        pop cx
        
        loop lp

   @exit:
            int 20h
@govno:
        mov dx , [si]
        mov ah , 02h
        int 21h
        jmp lp
end main

end start

; Здесь вводится буква, после чего вводится цифра(сдвиг)