.model small
.stack 256

.data
a dw 1 
b dw 2
c dw 3
d dw 4
result   dw   0

.code
main:
    mov ax,@data
    mov ds,ax
    mov bx,b
    mov cx,c
    cmp bx,cx ; проверяю (b < c)
    jl @FirstAns
    jge @FirstCondition

        @FirstCondition:                        ;  ((b * с) != (d - a))
            mov ax,bx
            imul cx
            mov dx,d
            mov cx,a
            sub dx,cx
            cmp ax,dx
            jne @FirstAns
            je @SecondCondition

                @FirstAns:                      ;  (3 * a + b * (c - d))
                   mov dx,d
                   mov cx,c
                   mov bx,b
                   sub cx,dx
                   mov ax,cx
                   mul bx
                   mov bx,ax
                   mov ax,a
                   add ax,a
                   add ax,a
                   add ax,bx
                   mov result,ax
                   jmp @exit

        @SecondCondition:                       ; (a < b)
            mov ax,a
            mov bx,b
            cmp ax,bx
            jl @LowSecCondit
            jge @ThirdAns
        
                @LowSecCondit:                  ;((a - d) < (b + c))
                    mov dx,d
                    mov cx,c
                    sub ax,dx
                    add bx,cx
                    cmp ax,bx
                    jl @SecondAns
                    jge @ThirdAns

                        @SecondAns:             ; (a * a - b + c) 
                            mov ax,a
                            mov bx,b
                            mov cx,c
                            mul ax
                            add ax,cx
                            sub ax,bx
                            mov result,ax
                            jmp @exit

                        @ThirdAns:              ; (2 * b - 5 * d + 3)
                            mov bx,b
                            mov ax,d
                            mov si,5
                            mul si
                            mov dx,ax
                            add bx,bx
                            add bx,3
                            sub bx,dx
                            mov result,bx
                            jmp @exit
    
    @exit:
        mov dx,result
        mov ah,09h
        int 21
        mov ah, 4ch
        int   21h
end main
;if ((b * с) != (d - a)) or (b < c):        
;    print(3 * a + b * (c - d))       FIRST ANS
;else:
;    if ((a - d) < (b + c)) and (a < b):
;        print(a * a - b + c)               SECOND ANS
;    else:
;        print(2 * b - 5 * d + 3)           THIRD ANS
