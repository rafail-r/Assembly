include macros
include lib_extr

data_seg segment
    newline db 0ah, 0dh, "$"    
data_seg ends

stack_seg segment stack
    dw   128  dup(0)
stack_seg ends

code_seg segment  
    assume cs:code_seg, ds:data_seg
main proc far
	mov ax,data_seg
	mov ds,ax
	mov es,ax
start:
	call read_number       	;anagnosi protou arithmou
				;kai sximatismos ston BX
	push bx                		;apothikeysi tou protou arithmou sti stiva
	call read_number2	   	;anagnosi deyterou arithmou
				;kai sximatismos ston BX
	mov dx,bx		;apothikeysi tou deyterou arithmou ston DX
	pop bx			;kai epanafora tou protou arithmou apo ti stiva
	call result		;ipologismos kai ektiposi apotelesmatos
	print_str newline
	jmp start			;sinexis litourgia
main endp
code_seg ends
end main 