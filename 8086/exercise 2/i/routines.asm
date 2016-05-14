include macros
public read_number
public print_hex
public read_number2
public result

stack_seg segment stack
	dw 50 dup (?)
stack_seg ends

code_seg segment
	assume cs:code_seg, ss:stack_seg
read_number proc far			;� ������� �������� ��� ����� ������ ��� �� ������������
	mov cl,0					;���������� ������� ������ 
	mov bx,0					;������������� ��� 0 ��� ������ ��� �� �����������
start0:
	read						;�������� ���������
	cmp al,'Q'	
	je quit0
	cmp al,'q'
	je quit0					;�� ����� ������� ������ �����������
	cmp al,'0'
	jl start0
	cmp al,'9'
	jg start0					;������� ��� ����� (0-9)
	print al					;�������� ���������
	sub al,'0'					;��������� �� ������� ������
	char_dec					;����������� ��� ������ �������
								;(�� ������� �����)	
	inc cl						;������ ������� ������
start1:
	read						;�������� ��������� 
	cmp al,'Q'
	je quit0
	cmp al,'q'
	je quit0					;�� ����� ������� ������ �����������
	cmp al,'+'					
	je return0
	cmp al,'-'
	je return0					;�� ����� ������� ������ (+/-) ���������
	cmp al,'0'					;������ ������� ��� �������� �����
	jl start1
	cmp al,'9'
	jg start1
	print al					;�������� ���������
	sub al,'0'					;��������� �� ������� ������
	char_dec					;����������� ��� ������ �������       
	inc cl						;������ ������� ������
	cmp cl,4					;�� ����� ����� 4 �����
	je oper						;����������� ������� ������
	jmp start1					;������ ���������
oper:
	read						;�������� ���������
	cmp al,'Q'
	je quit0
	cmp al,'q'
	je quit0					;�� ����� ������� ������ �����������
	cmp al,'+'
	je return0			
	cmp al,'-'		
	je return0					;�� ����� ������� ������ (+/-) ���������
	jmp oper					;����������� ����� �� ����� ������� ������
return0:
	mov ch,al					;���������� �������� ������
	print al					;��� �������� ���
	ret							;��������� ��� ����� ���������
quit0:
	exit						
read_number endp

print_hex proc far 
        cmp al,0               ;��� ��� ������ ���� �� ����� �� �������� �����
							   ;��� ���������
        je done 			   ;� ������� ���� ���������� ��� ����������� �����
        cmp bl,9               ;(���. ���� ������� ������ ��� 4 bit) ���� ����������
        jle addr4              ;��������� ��� ��� ������� ���� �����
        add bl,37h
        jmp addr5
        addr4:
            add bl,'0'
        addr5: 
            print bl
		done:
			ret
print_hex endp

read_number2 proc far			;� ������� �������� ��� ������� ������ ��� �� ������������
	mov cl,0					;���������� ������� ������
	mov bx,0					;������������� ��� 0 ��� ������ ��� �� �����������
start2:
	read						;�������� ���������
	cmp al,'Q'
	je quit1
	cmp al,'q'
	je quit1					;�� ����� ������� ������ �����������				
	cmp al,'0'
	jl start2
	cmp al,'9'				
	jg start2					;������� ��� ����� (0-9)
	print al					;�������� ���������
	sub al,'0'					;��������� �� ������� ������
	char_dec					;����������� ��� �������� �������
	inc cl						;������ ������� ������
start3:
	read                        ;�������� ���������
	cmp al,'Q'
	je quit1
	cmp al,'q'
	je quit1					;�� ����� ������� ������ �����������
	cmp al,3dh	
	je return1					;�� ����� = ���������
	cmp al,'0'
	jl start3
	cmp al,'9'
	jg start3
	print al					;�� ����� ����� (0-9) ��������
	sub al,'0'					;��������� ��������� �� ������� ������
	char_dec					;����������� ��� �������� �������
	inc cl						;������ ������� ������
	cmp cl,4					;�� ����� ����������� 4 �����
	je ent						;����������� =
	jmp start3					;������ ���������
ent:
	read						
	cmp al,'Q'
	je quit1
	cmp al,'q'
	je quit1					;�� ����� ������� ������ �����������
	cmp al,3dh
	je return1					;�� ����� = ���������
	jmp ent						;������ ����������� �� ����������� ��� =
return1:
	ret
quit1:
	exit
read_number2 endp

result proc far					;������� ����������� ��� ��������� �������������
	push dx						;� DX (������� 2) ����������� ��� ��� macro PRINT 
								;�� ���� ��� ������� ���� ������
	print '='					;��������� '=' 
	pop dx						;��������� ��� DX ��� �� ������
	cmp ch,'+'					;������� �������� ������
	je addn						;�� ������ (+) ���� ��� addn ��� ��������
								;������ �������� (-)
	mov ch,0					;������ ��������� �������� = 0 (false)
	cmp bx,dx					;����������� BX,DX (������� 1, ������� 2)
	jl minus					;�� �� < DX (���. BX - DX < 0) ���� ��� minus
	sub bx,dx					;������ ������� �������� ��� �������� BX - DX
								;(���������� ���� BX)
	jmp prnt					;���� ��� prnt ��� �������� ��� �������������
addn:
	add bx,dx					;�������� BX + DX ��� �� ���������� ���� BX
	jmp prnt					;���� ��� prnt ��� �������� ��� �������������
minus:
	push dx	
	print '-'					;�������� ��������� ��������
	pop dx						;������� ��� ������ ��� ��� �������� ������������ ��� DX
	mov ch,1					;������ ��������� ������������� = 1 (true)
	sub dx,bx					;������� � �������� DX - BX (DX - BX > 0)
	mov bx,dx					;���������� ������������� ���� BX
prnt:
	mov al,0					;������ ������ <> 0 ������ = 0 (false)
	push bx						;���������� ������������� ��� ������
	and bx,0f000h				;��������� 4 MSB (1�� hex ������)
	jz continue1				;�� �� ����� ����� 0 ��������
	mov al,1					;������ ����� � ������ ������ <> 0 ������ ������� 1 (true)
								;(������ ���� �� ����� �� �������� ����� ��� ��������)
continue1:
	mov cl,12              
	shr bx,cl                   ;���������� hex ������ ��� ����� ����
	call print_hex				;��� ��������
	pop bx						;��������� �������������
	push bx						;��������������� �� ���������� ��� �� ������� hex �����
								;��� ������������� (�������� ������ 4 hex �����)
	and bx,0f00h
	jz continue2
	mov al,1
continue2:
	mov cl,8
	shr bx,cl
	call print_hex
	pop bx
	push bx
	and bx,0f0h
	jz continue3
	mov al,1
continue3:
	mov cl,4
	shr bx,cl
	call print_hex
	pop bx
	push bx
	and bx,0fh
	mov al,1
	call print_hex
	pop bx
	print '='					 ;�������� '='
	cmp ch,1					 ;������� ������� ��������� �������������
	jne proceed					 ;�� ����� false �����������
	print '-'					 ;������ ����� ��������� ����� (-)
proceed:						 ;��� ��������� �� ���������� (�� ������� �����)
								 ;��� ���������� ��� ���� ��� �� �������� ��� �����
	mov cx,0   	;���������� ������� ������
	mov ax,bx
addr2:
	mov dx,0
	mov bx,10
	div bx		;�������� ��� ������ �� �� 10
	push dx		;���������� �� �������� ��� ������
	inc cx		;������ �� ������� ������
	cmp ax,0	;���� �� ������ ����� 0 ��� ������� ���� �����
	jnz addr2
addr3:
	pop dx		;������� ��� �� ������ ��� �����
	add dx,30h	;��������� �� ��������� ��� ��������
	print dl
	loop addr3
	ret
result endp
code_seg ends
end