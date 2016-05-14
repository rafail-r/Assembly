/*
 * 2.3.asm
 *
 *  Created: 16/12/2014 7:43:16 ??
 *   Author: Rafail
 */ 

.include "m16def.inc"				; ������ ������������

.org 0x0							; � ���� ��� ������ (reset) �����
rjmp reset							; �� ��������� ���� �/�� 0x0.

.org 0x2							; � ����������� ��� INT0
rjmp ISR0							; �������� ���� �/�� 0x2.

.org 0x10
rjmp ISR_TIMER1_OVF					; ������� ������������ ��� �������� ������������ ��� timer1

;****************************************************************************************************;

reset:
	ldi r16,high(RAMEND)			
	out SPH,r16
	ldi r16,low(RAMEND)
	out SPL,r16						; ������������ ��� ������ �������

	ldi r24,(1<<ISC01)|(1<<ISC00)	; �������� � ������� INT0 ��
	out MCUCR,r24					; ����������� �� ���� ������� �����.									
	ldi r24,(1<<INT0)				; ������������ �� ������� INT0.
	out GICR,r24

	ldi r24,(1 << TOIE1)			; ������������ �������� ������������ ��� ������� TCNT1
	out TIMSK,r24					; ��� ��� timer1.

	sei								; ������������ ��� ��������� ��������.

	ldi r24,(1<<CS12)|(0<<CS11)|(1<<CS10)	; CK/1024
	out TCCR1B,r24
	
	ldi r16,0b00000001				; �������� �� bit(0) ��� PORTA �� ������.
	out DDRA,r16					; bit(0)-PORTA --> �������
			
	ldi r16,0b11111110				; �������� �� �������� bit ��� PORTA �� �����.
	out DDRA,r16					; bit(7-1)-PORT� --> ������
	
check:
	sbis PINA,0						;loop ����� PA0=1
	rjmp check


	ldi r16,0b00000010			
	out PORTA,r16					; �������� �� PA1

	ldi r24,0xA4					; ������������ ��� TCNT1... 65536-3*7812.5=42098=A472
	out TCNT1H,r24		
	ldi r24,0x72			
	out TCNT1L,r24					; ...��� ����������� ���� ��� 3 sec.
		

check1:								;loop ����� PA0=0
	sbis PINA,0
	rjmp check
	rjmp check1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ISR0:
	cli								; Clear the global interrupt flag in SREG 
									; so prevent any form of interrupt occurring.
	in r26,SREG						; ���� �� ����������� ��� SREG
	push r26
intrloop:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  Start of Debouncing (= ���������������) ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 		

	ldi r24,(1 << INTF0)						
	out GIFR,r24					; �������� �� bit6 ��� GIFR

	ldi r24 , low(5)				
	ldi r25 , high(5)				; load r25:r24 with 5		
	rcall wait_msec					; delay  5 ms

	in r24,GIFR
	andi r24, 0x40					;�� �� 2oMSB (intf0)
	brne intrloop					;����� ����� 1, loop

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  End of Debouncing (= ���������������) ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;		

	ser r24							; set register r24						
	
	ldi r16,0b00000010			
	out PORTA,r16					; �������� �� PA1
	
	ldi r24,0xA4					; ������������ ��� TCNT1... 65536-3*7812.5=42098=A472
	out TCNT1H,r24		
	ldi r24,0x72			
	out TCNT1L,r24					; ...��� ����������� ���� ��� 3 sec.
	
	pop r26
	out SREG,r26					; ��������� SREG
	
	reti							; ��������� ��� ������� ��� ����� ���������

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ISR_TIMER1_OVF:
	in r26,SREG			
	push r26						; ���� �� ����������� ��� SREG.

	ldi r16,0b00000000			
	out PORTA,r16					; �������� �� LED PA1. 

	pop r26
	out SREG,r26					; ��������� SREG

	reti							; ��������� ��� ������� ��� ����� ���������.

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

wait_usec:   
	sbiw r24 ,1			; 2 ������ (0.250 �sec)  
	nop           		; 1 ������ (0.125 �sec)
	nop          		; 1 ������ (0.125 �sec)
	nop           		; 1 ������ (0.125 �sec)
	nop           		; 1 ������ (0.125 �sec)
	brne wait_usec		; 1 � 2 ������ (0.125 � 0.250 �sec)
    ret					; 4 ������ (0.500 �sec)

wait_msec:				;(10) ��� simulation
   	push r24			; 2 ������ (0.250 �sec)
   	push r25			; 2 ������
 	ldi r24 , low(998)  ; ������� ��� �����.  r25:r24 �� 998 (1 ������ - 0.125 �sec)
  	ldi r25 , high(998) ; 1 ������ (0.125 �sec)
   	rcall wait_usec     ; 3 ������ (0.375 �sec), �������� �������� ����������� 998.375 �sec       
   	pop r25             ; 2 ������ (0.250 �sec)
   	pop r24             ; 2 ������ 
   	sbiw r24 , 1        ; 2 ������ 
   	brne wait_msec      ; 1 � 2 ������ (0.125 � 0.250 �sec)
   	ret					; 4 ������ (0.500 �sec)