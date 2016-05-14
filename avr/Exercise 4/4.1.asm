/*
 * 4.1.asm
 *
 *  Created: 20/1/2015 12:04:36 ??
 *   Author: Rafail
 */ 


.include "m16def.inc"

jmp reset

reset:	ldi r24,low(RAMEND)
		out SPL,r24
		ldi r24,high(RAMEND)
		out SPH,r24

		ldi r24,(1<<PC7)|(1<<PC6)|(1<<PC5)|(1<<PC4)
		out DDRC,r24		; Initialize PORTC half as output, half as input. output 4MSB C  (keypad 3.3)

		ser r24
		out DDRD,r24		; output D
		clr r24
		
		rcall lcd_init
		ldi r24,low(100)
		ldi r25,high(100)
		rcall wait_usec
							; default print
		ldi r24,'K'
		rcall lcd_data
		ldi r24,'E'
		rcall lcd_data
		ldi r24,'N'
		rcall lcd_data
		ldi r24,'O'
		rcall lcd_data
							
scan:	ldi r24,10			; scan mexri input
		rcall scan_keypad_rising_edge
		rcall keypad_to_ascii
		tst r24
		breq scan
		push r24

		ldi r24,0x01		; katharismos tis othonis (apo pdf 4)
		rcall lcd_command
		ldi r24,low(1530)
		ldi r25,high(1530)
		rcall wait_usec

		pop r24
		rcall lcd_data		; keypad print
		rjmp scan			


.include "wait.asm"			; apo pdf 4
.include "lcd.asm"			; apo pdf 4
.include "keypad.asm"		; apo 3.3