.include "m16def.inc"


mylockcode:

scan1:
	ldi r24,0x44 //Όρισμα της scan_keypad_rising_edge για DELAY
	rcall scan_keypad_rising_edge
	rcall keypad_to_ascii
	cpi r24,'1'
	brne  scan1
	rcall lcd_data
	
scan1_1:
	ldi r24,0x16 //Όρισμα της scan_keypad_rising_edge για DELAY
	rcall scan_keypad_rising_edge
	rcall keypad_to_ascii
    cpi r24,'1'
	brne scan1_1
	rcall lcd_data

scan2:
	ldi r24,0x16 //Όρισμα της scan_keypad_rising_edge για DELAY
	rcall scan_keypad_rising_edge
	rcall keypad_to_ascii
    cpi r24,'2'
	brne scan2
	rcall lcd_data

ret
