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

makeIntend proc near
    lea dx, indent
    mov ah, 09
    int 21h
    ret
makeIntend endp



