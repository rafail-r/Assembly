/*
 * 4.2.asm
 *
 *  Created: 20/1/2015 6:22:07 ??
 *   Author: Rafail
 */ 


.include "m16def.inc"				; δήλωση μικροελεγκτή

.def metritis=r17


.org 0x0							; Η αρχή του κώδικα (reset) πάντα
rjmp reset							; θα δηλώνεται στην δ/ση 0x0.

.org 0x10
rjmp ISR_TIMER1_OVF					; ρουτίνα εξυπηρέτησης της διακοπής υπερχείλισης του timer1



RESET:
	ldi metritis,0x00	

	ldi r24 , low(RAMEND) 
	out SPL , r24
	ldi r24 , high(RAMEND)
	out SPH , r24			; initialize stack pointer
    
	ldi r24 ,(1 << PC7) | (1 << PC6) | (1 << PC5) | (1 << PC4)	
    out DDRC ,r24			; Initialize PORTC half as output, half as input. output 4MSB C  (keypad 3.3)
	
	ldi r24,0b00000000
	out PORTC,r24

	ser r24
	out DDRD,r24		; output D
    ser r28
    out DDRA, r28     ; port A as output 
    clr r28 
	out DDRB, r28     ; port B as input

	rcall lcd_init
    
    ldi r24 ,low(100)
	ldi r25 ,high(100)
	call wait_usec
	rcall calibration_timer1

nochange:
	in r28,PINB
	tst r28				; Έλεγχος μηδενικής τιμής.
	breq nochange		; Θέλουμε τουλάχιστον ένα πατημένο
						; για ενεργοποίηση συναγερμού.
  	rcall start_timer	; Πήραμε τιμή, clock is ticking...
	
	ldi r24,0x0F		;cursor on 0b00001DCB
	rcall lcd_command

	rcall mylockcode
	cli
	ldi r24,2
	rcall lcd_command
	ldi r24 ,low(1580)  
	ldi r25 ,high(1580)
	rcall wait_usec
	ldi r24,0x0c		;cursor off
	rcall lcd_command
	rcall message_alarm_off

loop:	
	jmp loop
	

ISR_TIMER1_OVF:
	cli
	inc metritis
	cpi metritis,0x02
	brne second_count
	ldi r24,2
	rcall lcd_command
	ldi r24 ,low(1580)  
	ldi r25 ,high(1580)
	rcall wait_usec
	ldi r24,0x0c		;cursor off
	rcall lcd_command
	rcall message_alarm_on
alarm:
	ldi r25,high(4000)
	ldi r24,low(4000)	; καθυστέρηση = 400 ms = 0.4 s
	rcall on_a
	rcall wait_msec		;εισαγωγή χρονοκαθυστέρησης 
	ldi r25,high(1000)
	ldi r24,low(1000)	; καθυστέρηση = 100 ms = 0.1 s
	rcall off_a
	rcall wait_msec		;εισαγωγή χρονοκαθυστέρησης
	;cli
	jmp alarm
		
second_count:
	rcall calibration_timer1
	rcall start_timer
	sei
exit:		    
	reti


.include "wait.asm"
.include "lcd.asm"
.include "pad.asm"
.include "timer.asm"
.include "messages.asm"
.include "mylock.asm"
