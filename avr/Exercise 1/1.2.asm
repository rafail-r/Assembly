/*
 * 1.2.asm
 *
 *  Created: 6/12/2014 9:58:11 ??
 *   Author: Rafail
 */ 

 .include "m16def.inc"


ldi r26,low(ramend)
out spl,r26
ldi r26,high(ramend)
out sph,r26				; ������������ ������ �������

ser r26         		; ������������ ��� PORTA 
out DDRA,r26   			; ��� ����� 

clr r26					
out DDRB,r26			; ������������ ��� PORTB ��� ������
ldi r26,0b11111111		; ������������ pull-up ����������� ���� PORTB
out PORTA,r26


main:	
	rcall on 			; ����� �� LEDs
	rcall off 			; ����� �� LEDs
	rjmp main	  		; ���������
						
on:						; ���������� ��� �� ������� �� LEDs
	ser r26				; ���� �� ���� ������ ��� LEDs
	out PORTA,r26	
	rcall delay_on
	ret					; ������ ��� ����� ���������

						
off:					; ���������� ��� �� ������� �� LEDs
	clr r26				; �������� �� ���� ������ ��� LEDs
	out PORTA,r26
	rcall delay_off	
	ret					; ������ ��� ����� ���������

delay_on:
	ldi r25,0			
	ldi r24,100			; ������������ ����������������� ��� 100 msec
	in r26, PINB		; ���������� �� dip switches
	andi r26, 0x0f		; ��������� ��� 4 LSB (��� ������)
	breq done			; �� ����� ����� ������� ������ ��� ������� wait_msec
add100:					
	adiw r24,50
	adiw r24,50
	dec r26
	brne add100			; ������ ����� ������������ ��� ����������� 
						; [R25:R24 = R26*100 + 100]
done:
	rcall wait_msec
    ret

delay_off:
	ldi r25,0			
	ldi r24,100			; ������������ ����������������� ��� 100 msec
	in r26, PINB		; ���������� �� dip switches
	andi r26, 0xf0		; ��������� ��� 4 MSB (��� �������)		
	lsr r26
	lsr r26
	lsr r26
	lsr r26				; 4 shift right
	breq donef			; �� ����� ����� ������� ������ ��� ������� wait_msec
add100f:
	adiw r24,50
	adiw r24,50
	dec r26
	brne add100f		; ������ ����� ������������ ��� ����������� 
						; [R25:R24 = R26*100 + 100]
donef:
	rcall wait_msec
    ret

wait_usec:   
	sbiw r24,1      	; 2 ������ (0.250 �sec)  
	nop           		; 1 ������ (0.125 �sec)
	nop          		; 1 ������ (0.125 �sec)
	nop           		; 1 ������ (0.125 �sec)
	nop           		; 1 ������ (0.125 �sec)
	brne wait_usec		; 1 � 2 ������ (0.125 � 0.250 �sec)
    ret             	; 4 ������ (0.500 �sec)

wait_msec:				; ��� simulation (10) ���� ��� (998) ��� rate=ultimate
   	push r24			; 2 ������ (0.250 �sec)
   	push r25			; 2 ������
 	ldi r24 , low(998)	; ������� ��� �����.  r25:r24 �� 998 (1 ������ - 0.125 �sec)
  	ldi r25 , high(998)	; 1 ������ (0.125 �sec)
   	rcall wait_usec     ; 3 ������ (0.375 �sec), �������� �������� ����������� 998.375 �sec       
   	pop r25             ; 2 ������ (0.250 �sec)
   	pop r24             ; 2 ������ 
   	sbiw r24 , 1        ; 2 ������ 
   	brne wait_msec      ; 1 � 2 ������ (0.125 � 0.250 �sec)
   	ret					; 4 ������ (0.500 �sec)
