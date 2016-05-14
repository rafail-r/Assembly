.include "m16def.inc"



lcd_init:
	ldi r24 ,40 
	ldi r25 ,0 
	rcall wait_msec 
	ldi r24 ,0x30 
	out PORTD ,r24
	sbi PORTD ,PD3 
	cbi PORTD ,PD3
	ldi r24 ,39
	ldi r25 ,0 
	rcall wait_usec 
	ldi r24 ,0x30
	out PORTD ,r24
	sbi PORTD ,PD3
	cbi PORTD ,PD3
	ldi r24 ,39
	ldi r25 ,0
	rcall wait_usec
	ldi r24 ,0x20 
	out PORTD ,r24
	sbi PORTD ,PD3
	cbi PORTD ,PD3
	ldi r24 ,39
	ldi r25 ,0
	rcall wait_usec
	ldi r24 ,0x28 
	rcall lcd_command 
	ldi r24 ,0x0C;              IF YOU WANT blinking cursor  0F? ELSE 0C
	rcall lcd_command
	ldi r24 ,0x01 
	rcall lcd_command
	ldi r24 ,low(1530)
	ldi r25 ,high(1530)
	rcall wait_usec
	ldi r24 ,0x06 
	rcall lcd_command 
ret

lcd_command:
	cbi PORTD ,PD2 ;(PD2=1)
	rcall write_2_nibbles 
	ldi r24 ,39 
	ldi r25 ,0 
	rcall wait_usec 
ret

write_2_nibbles:
	push r24 ; ������� �� 4 MSB
	in r25 ,PIND ; ����������� �� 4 LSB ��� �� �������������
	andi r25 ,0x0f ; ��� �� ��� ��������� ��� ����� ����������� ���������
	andi r24 ,0xf0 ; ������������� �� 4 MSB ���
	add r24 ,r25 ; ������������ �� �� ������������ 4 LSB
	out PORTD ,r24 ; ��� �������� ���� �����
	sbi PORTD ,PD3 ; ������������� ������ �nable ���� ��������� PD3
	cbi PORTD ,PD3 ; PD3=1 ��� ���� PD3=0
	pop r24 ; ������� �� 4 LSB. ��������� �� byte.
	swap r24 ; ������������� �� 4 MSB �� �� 4 LSB
	andi r24 ,0xf0 ; ��� �� ��� ����� ���� �������������
	add r24 ,r25
	out PORTD ,r24
	sbi PORTD ,PD3 ; ���� ������ �nable
	cbi PORTD ,PD3
ret




lcd_data:
	sbi PORTD ,PD2 ; (PD2=1)
	rcall write_2_nibbles ; 
	ldi r24 ,43 ; 
	ldi r25 ,0 ;
	rcall wait_usec
ret

