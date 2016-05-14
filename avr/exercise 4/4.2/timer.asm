.include "m16def.inc"


calibration_timer1:

	ldi r24,0x67	    ; Αρχικοποίηση του TCNT1... 65536-5*7812.5=26476=676C
	out TCNT1H,r24      
	ldi r24,0x6c
	out TCNT1L,r24		; για υπερχείλιση μετά από 5 sec

	ldi r24,(1<<TOIE1)  ; ενεργοποίηση διακοπής υπερχείλισης του μετρητή TCNT1
	out TIMSK,R24 	    ; για τον timer1
	sei

ret


start_timer:
	ldi r24,(1<<CS12) | (0<<CS11) | (1<<CS10) ; CK/1024
	out TCCR1B,r24
	sei
ret

