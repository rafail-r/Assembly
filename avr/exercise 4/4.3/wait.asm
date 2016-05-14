.include "m16def.inc"

wait_usec:
sbiw r24 ,1 ; 2 ������ (0.250 �sec)
nop ; 1 ������ (0.125 �sec)
nop ; 1 ������ (0.125 �sec)
nop ; 1 ������ (0.125 �sec)
nop ; 1 ������ (0.125 �sec)
brne wait_usec ; 1 � 2 ������ (0.125 � 0.250 �sec)
ret ; 4 ������ (0.500 �sec)


wait_msec:
push r24 ; 2 ������ (0.250 �sec)
push r25 ; 2 ������
ldi r24 , low(998) ; ������� ��� �����. r25:r24 �� 998 (1 ������ - 0.125 �sec)
ldi r25 , high(998) ; 1 ������ (0.125 �sec)
rcall wait_usec ; 3 ������ (0.375 �sec), �������� �������� ����������� 998.375 �sec
pop r25 ; 2 ������ (0.250 �sec)
pop r24 ; 2 ������
sbiw r24 , 1 ; 2 ������
brne wait_msec ; 1 � 2 ������ (0.125 � 0.250 �sec)
ret ; 4 ������ (0.500 �sec)


testbutton:	
	in r24,PINB
	cpi r24, 0x01
	breq testbutton
ret

;���������� ��� �� ������� �� LEDs

on: ser r26 ; ���� �� ���� ������ ��� LED
out PORTA , r26
ret ; ������ ��� ����� ���������
;���������� ��� �� ������� �� LEDs

off: clr r26 ; �������� �� ���� ������ ��� LED
out PORTA , r26
ret ; ������ ��� ����� ���������