/*
 * 1.1.asm
 *
 *  Created: 6/12/2014 9:08:35 ??
 *   Author: Rafail
 */ 

 .include "m16def.inc"						;������ ������������

.def temp = r16
.def output = r17
.def count = r18							;�������� �����������							
.equ delay = 500							;������ ��������

ldi temp,low(ramend)
out spl,temp
ldi temp,high(ramend)						
out sph,temp								;������������ ������ �������

clr temp
out DDRB,temp								;� PORTB �������

ser temp
out DDRA,temp								;� PORTA ������

ldi output,0x80								;1000 0000
out PORTA,output							;�������� �� ������������ led
ldi r25,high(delay)
ldi r24,low(delay)							;����������� = 500 ms = 0.5 s
rcall wait_msec								;�������� �����������������

main:
	ldi count,7								;������������ ������� ����������
	rcall right								;����� ������ ���� �� ����� 
	ldi count,7								;��������� ��� ������� ����������
	rcall left								;��� �������� ������ ���� �� ��������
	rjmp main								;��������� ��� ������ ����������
	
left:
	in temp,PINB							;������� ��� ������ ��� push button
	sbrc temp,0								;�� ��� ����� �������� �����������
	rjmp left								;������ �������������
	lsl output								;�������� ��� led ���� �� ��������
	out PORTA,output						;������ ���� PORTA
	ldi r25,high(delay)
	ldi r24,low(delay)						;����������� = 500 ms = 0.5 s
	rcall wait_msec							;�������� �����������������
	dec count								;������ ������� ����������
	brne left								;��� ��� ����� ����������� 7 ���������� ���������
	ret										;������ ��������� ��� ����� ���������

right:
	in temp,PINB							;������� ��� ������ ��� push button
	sbrc temp,0								;�� ��� ����� �������� �����������
	rjmp right								;������ �������������
	lsr output								;�������� ��� led ���� �� �����
	out PORTA,output						;������ ���� PORT�
	ldi r25,high(delay)
	ldi r24,low(delay)						;����������� = 500 ms = 0.5 s
	rcall wait_msec							;�������� �����������������
	dec count								;������ ������� ����������
	brne right								;��� ��� ����� ����������� 7 ���������� ���������
	ret										;������ ��������� ��� ����� ���������

wait_usec:   
	sbiw r24 ,1      						; 2 ������ (0.250 �sec)  
	nop           							; 1 ������ (0.125 �sec)
	nop          							; 1 ������ (0.125 �sec)
	nop           							; 1 ������ (0.125 �sec)
	nop           							; 1 ������ (0.125 �sec)
	brne wait_usec							; 1 � 2 ������ (0.125 � 0.250 �sec)
    ret										; 4 ������ (0.500 �sec)

wait_msec:									
   	push r24								; 2 ������ (0.250 �sec)
   	push r25								; 2 ������
 	ldi r24 , low(998)      				; ������� ��� �����.  r25:r24 �� 998 (1 ������ - 0.125 �sec)
  	ldi r25 , high(998)     				; 1 ������ (0.125 �sec)
   	rcall wait_usec        					; 3 ������ (0.375 �sec), �������� �������� ����������� 998.375 �sec       
   	pop r25               					; 2 ������ (0.250 �sec)
   	pop r24               					; 2 ������ 
   	sbiw r24 , 1          					; 2 ������ 
   	brne wait_msec        					; 1 � 2 ������ (0.125 � 0.250 �sec)
   	ret										; 4 ������ (0.500 �sec)
