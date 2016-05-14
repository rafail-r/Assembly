.include "m16def.inc"
;alarm on / alarm off
message_alarm_on:
	ldi r24,'A'     	;A
	rcall lcd_data

	ldi r24,'L'     	;L
	rcall lcd_data

    ldi r24,'A'   		;A
	rcall lcd_data

	ldi r24,'R'  		;R
	rcall lcd_data

	ldi r24,'M'  		;M
	rcall lcd_data

    ldi r24,0x20     	;KENO
 	rcall lcd_data

    ldi r24,'O'     	;O
	rcall lcd_data

    ldi r24,'N'     	;N
	rcall lcd_data
	
ret

message_alarm_off:
	ldi r24,'A'     	;A
	rcall lcd_data

	ldi r24,'L'     	;L
	rcall lcd_data

    ldi r24,'A'   		;A
	rcall lcd_data

	ldi r24,'R'  		;R
	rcall lcd_data

	ldi r24,'M'  		;M
	rcall lcd_data

    ldi r24,0x20     	;KENO
 	rcall lcd_data

    ldi r24,'O'     	;O
	rcall lcd_data

    ldi r24,'F'     	;F
	rcall lcd_data
	
	ldi r24,'F'     	;F
	rcall lcd_data
ret
