.model small
.stack 512

.data 
indent  db '', 0Dh, 0Ah, '$'
enterString db 'Enter string: $'
alphabet db 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'
badInput db 'Bad input$'
actLen dw 0

inputString label byte
maxlenInput db 201
actlenInput dw ?
fldInput db 201 dup('$')

outputString label byte
maxlenOutput db 201
actlenOutput db ?
fldOutput db 201 dup('$')

.code

makeIntend proc near  ; отступ
    lea dx, indent
    mov ah, 09
    int 21h
    ret
makeIntend endp

searchSize proc near     ; Ищем размер введённой строки
        push cx

        xor cx,cx
        mov cx, actlenInput
        xor ch,ch
        mov actLen,cx
        
        pop cx
        ret
searchSize endp

parse proc near ; проверка на говно 
    push ds    
    pop es

    push cx
    push ax
    push di
    push bx

    mov bx , 2
    mov cx , actLen
    @lp:
    call parseHelp
    inc bx
    loop @lp

    pop bx
    pop di
    pop ax
    pop cx
    ret
parse endp

lettersSort proc near ; внешний цикл пузырька
    push ds    
    pop es

    push cx
    push ax
    push di
    push bx

    xor cx,cx
    xor ax,ax
    xor bx,bx
    xor di,di
    
    mov cx , actLen
    
    sub cx,1

    @lp1:   
    call help
    loop @lp1
    
    pop bx
    pop di
    pop ax
    pop cx
    ret
lettersSort endp

help proc near ; сортировка сраным пузырём и то не оптимизированная
    push ds    
    pop es

    push cx
    push ax
    push di
    push bx
    push dx
    xor dx,dx

    mov cx , actLen
    mov bx , 2
    sub cx,1

    @lp2:
    mov al ,[ inputString + bx ]
    mov dl ,[ inputString + bx + 1 ]
    cmp al,dl
    jg @swap
    jl @continue

    @swap:
    xchg al,dl
    mov [inputString + bx] , al
    mov [inputString + bx + 1 ] , dl
    @continue:
    inc bx
    loop @lp2
    
    pop dx
    pop bx
    pop di
    pop ax
    pop cx
    ret
help endp

parseHelp proc 
    push ds    ; подготавливаем регистры для цепочечных команд
    pop es

    push cx
    push ax
    push di
    
    xor ax,ax
    xor cx,cx
    xor di,di

    mov cx, 52
    cld
    mov al ,[ inputString + bx] ; +2 это переход ИМЕННО к началу строки. Далее +3 это уже ко второму символу
    lea di, alphabet 
    repnz scasb
    jnz @BadInput    ; если не найден

    pop di
    pop ax
    pop cx
    ret
parseHelp endp

start:
    mov ax,@data
    mov ds,ax

        lea dx, enterString                                 ; Ввод строки   
        mov ah, 09
        int 21h
        lea dx, inputString
        mov ah, 0Ah
        int 21h
        lea bx, inputString + 1  

        call makeIntend
        
        call searchSize ; ищем размер строки 

        call parse ; проверяем , что за строку нам дали   

        call lettersSort
        jmp @PrintAns
        jmp @exit

@BadInput:
        lea dx, badInput
        mov ah,09
        int 21h 
        jmp @exit
@PrintAns:
        lea dx, inputString + 2     ; я охуел от количества попыток увидеть, что срёт первые два символа в строку                      
        mov ah, 09
        int 21h                         
@exit:
        mov ah, 4ch
        int   21h

end start
