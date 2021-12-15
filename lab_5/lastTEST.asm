.model small

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
indent  db '', 0Dh, 0Ah, '$'
alphabet db 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'

.code

UPPERorNUMBER proc near
push ax bx cx dx si
    mov al , [si]
    mov cx , 36
    mov bx,0
    @ALPA:
    lea di, [alphabet + bx]
    inc bx
    cmp al , [di]
    jz @govnoInFunc
    loop @ALPA
pop si dx cx bx ax
ret
@bb2:
pop si dx cx bx ax
jmp @lp
@govnoInFunc:
        mov dx , [si]
        mov ah , 02
        int 21h
        jmp @bb2
UPPERorNUMBER endp

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

start:
         mov ax,@data
         mov ds,ax
         
         mov cx, 100
    @lp:
        call makeIntend
        lea dx, Symbol
        mov ah, 0Ah
        int 21h     
        lea si , Symbol + 2 ; вычислять после каждого ввода
        call makeIntend
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        call UPPERorNUMBER
push cx
@EnterShift:
        push ax bx dx di si
        
        lea dx, parM
        mov ah, 0Ah
        int 21h
        xor bx,bx
        lea bx, parM+1
        
        call enterNum
        mov ax , di
        mov cx , ax   
        pop si di dx bx ax
        call makeIntend
@EnterEnd:    
        mov ah,09h
        int 21h
        pop cx        
        loop @lp

   @exit:
            mov ah, 4ch
            int   21h
@govno:
        mov dx , [si]
        mov ah , 02h
        int 21h
        jmp @lp
end start
