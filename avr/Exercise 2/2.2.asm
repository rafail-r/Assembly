/*
 * 2.2.asm
 *
 *  Created: 16/12/2014 4:16:14 ??
 *   Author: Rafail
 */ 

.include "m16def.inc"				; ������ ������������

.org 0x0							; � ���� ��� ������ (reset) �����
rjmp reset							; �� ��������� ���� �/�� 0x0.

.org 0x4							; � ����������� ��� INT1
rjmp ISR1							; �������� ���� �/�� 0x4.

;****************************************************************************************************;	

reset:	
	ldi r16,low(RAMEND)
	out SPL,r16
	ldi r16,high(RAMEND)
	out SPH,r16						; ������������ ��� ������ �������
	
	ser r24							; set register r24						
	out DDRA,r24					; PORTA --> ������
	out DDRC,r24					; PORTC --> ������
	clr r23							; clear register 23
	out DDRB,r23					; PORTB --> �������
		
	ldi r24,(1<<ISC11)|(1<<ISC10)	; �������� � ������� INT1 ��
	out MCUCR,r24					; ����������� �� ���� ������� �����.
	ldi r24,(1<<INT1)				; ������������ �� ������� INT1.
	out GICR,r24
	sei								; ������������ ��� ��������� ��������.

	clr r26							; �������� ��� ������� ��� ������ ������������.
loop:	
	out PORTA,r26					; ����� ��� ���� ��� ������� ������ ������������
	ldi r24,low(100)				
	ldi r25,high(100)				; load r25:r24 with 100
	rcall wait_msec					; delay 100 ms
	inc r26							; ������ ������� ������ ������������.
	rjmp loop						; ���������.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ISR1:
	intrloop:	
	cli								; Clear the global interrupt flag in SREG 
									; so prevent any form of interrupt occurring.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  Start of Debouncing (= ���������������) ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 		

	ldi r24,(1 << INTF1)						
	out GIFR,r24					; �������� �� bit7 ��� GIFR

	ldi r24 , low(5)				
	ldi r25 , high(5)				; load r25:r24 with 5		
	rcall wait_msec					; delay  5 ms

	in r24,GIFR
	andi r24, 0x80					;�� �� MSB (intf1)
	brne intrloop					;����� ����� 1, loop

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  End of Debouncing (= ���������������) ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
check:
	push r26						; ���� �� ����������� ��� r26 (�� ������� ��� ������ ������������)
	in r26,SREG
	push r26						; ��� SREG

	clc								;���������� carry
	clr r23							;r23=0
	ldi r18,0x08					;r18=8
	in r20,PINB						;������� �
check1:
	dec r18							;������ �������
	ror r20							;������ � �����, �� carry
	brcc cont						;������ C, �� carry=1
	inc r23							
cont:
	cpi r18,0x00					;������, �� ������ ��� �� bits �����
	brne check1						;������ ��������
	out PORTC,r23					;����� ��� ���� ��� ������� ��� � ��� C

	pop r26							
	out SREG,r26
	pop r26							; ��������� ����������� r26 ��� SREG.
	sei								; ������������ ��� ������� �������� ��� ���������� ����������.
	reti							; Interrupt Return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

wait_usec:   
	sbiw r24 ,1      				; 2 ������ (0.250 �sec)  
	nop           					; 1 ������ (0.125 �sec)
	nop          					; 1 ������ (0.125 �sec)
	nop           					; 1 ������ (0.125 �sec)
	nop           					; 1 ������ (0.125 �sec)
	brne wait_usec					; 1 � 2 ������ (0.125 � 0.250 �sec)
    ret								; 4 ������ (0.500 �sec)

wait_msec:							; (10)  ��� simulation
   	push r24						; 2 ������ (0.250 �sec)
   	push r25						; 2 ������
 	ldi r24 , low(998)    			; ������� ��� �����.  r25:r24 �� 998 (1 ������ - 0.125 �sec)
  	ldi r25 , high(998)     		; 1 ������ (0.125 �sec)
   	rcall wait_usec        			; 3 ������ (0.375 �sec), �������� �������� ����������� 998.375 �sec       
   	pop r25               			; 2 ������ (0.250 �sec)
   	pop r24               			; 2 ������ 
   	sbiw r24 , 1        			; 2 ������ 
   	brne wait_msec      			; 1 � 2 ������ (0.125 � 0.250 �sec)
   	ret								; 4 ������ (0.500 �sec)