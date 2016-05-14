/*
 * 3.1.asm
 *
 *  Created: 22/12/2014 4:52:16 ??
 *   Author: Rafail
 */ 


.include "m16def.inc"		; ������ ������������
.def input=r17
.def temp=r25
.def result=r24

.org 0x0					; � ���� ��� ������ (reset) �����
rjmp reset					; �� ��������� ���� �/�� 0x0.

reset:
	ldi r26,high(RAMEND)	
	out SPH,r26
	ldi r26,low (RAMEND)
	out SPL,r26				; ������������ ������ �������

	ser r26					; set register r26		
	out DDRC,r26			; portC --> ������

	clr r26					; clear register r26
	out DDRA,r26			; portA --> �������
	out DDRB,r26			; portB --> �������
	
start:
	in r26,pinB				; ���������� �� dip-switches ��� portB.
	mov input,r26			; ������������ ��� ������ ���� ���������� input.
	
	mov temp,input			; ������������ ��� ������ ���� ���������� temp.
	lsr input				; ���������� ��� bit1 ��� ��������� ����(0) ��� �� ����� � ����� �� �� bit0.				
	eor temp,input			; ���� 1 XOR					
	andi temp,0x01			; ��������� ��� bit0
	mov result,temp			; save
	
	mov temp,input			; ���������
	lsr input				; ���������� ��� bit3 ��� ��������� ����(1) ��� �� ����� � ����� �� �� bit2.
	and temp,input			; ���� 2 AND
	andi temp,0x02			; ��������� ��� bit1
	or result,temp			; save

	mov temp,input			; ���������
	lsr input				; ���������� ��� bit5 ��� ��������� ����(2) ��� �� ����� � ����� �� �� bit4.
	eor temp,input			; ���� 3 XNOR = (not)xor
	com temp				; not
	andi temp,0x04			; ��������� ��� bit2
	or result,temp			; save

	mov temp,input			; ���������
	lsr input				; ���������� ��� bit7 ��� ��������� ����(3) ��� �� ����� � ����� �� �� bit6.
	or temp,input			; ���� 4 OR
	andi temp,0x08			; ��������� ��� bit3
	or result,temp			; save

	mov temp,result
	lsr temp
	andi temp,0x04			; ��������� ��� bit2
	or result,temp			; ���� 5 OR

	in r26,PINA				; �������� ���������� PORTA
	eor result,r26			; A� ���� ������� �� PAx ������������� PCx !
	andi result,0x0F		; ��������� ��� bit 3..0
	out PORTC,result		; ������ ��� LEDs ����� ������ portC.
	rjmp start				; ��������� ��� ������ ����������.