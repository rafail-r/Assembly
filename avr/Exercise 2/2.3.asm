/*
 * 2.3.asm
 *
 *  Created: 16/12/2014 7:43:16 ??
 *   Author: Rafail
 */ 

.include "m16def.inc"				; δήλωση μικροελεγκτή

.org 0x0							; Η αρχή του κώδικα (reset) πάντα
rjmp reset							; θα δηλώνεται στην δ/ση 0x0.

.org 0x2							; Η εξυπηρέτηση της INT0
rjmp ISR0							; ορίζεται στην δ/ση 0x2.

.org 0x10
rjmp ISR_TIMER1_OVF					; ρουτίνα εξυπηρέτησης της διακοπής υπερχείλισης του timer1

;****************************************************************************************************;

reset:
	ldi r16,high(RAMEND)			
	out SPH,r16
	ldi r16,low(RAMEND)
	out SPL,r16						; αρχικοποίηση του δείκτη στοίβας

	ldi r24,(1<<ISC01)|(1<<ISC00)	; Ορίζεται η διακοπή INT0 να
	out MCUCR,r24					; προκαλείται με σήμα θετικής ακμής.									
	ldi r24,(1<<INT0)				; Ενεργοποίησε τη διακοπή INT0.
	out GICR,r24

	ldi r24,(1 << TOIE1)			; Ενεργοποίηση διακοπής υπερχείλισης του μετρητή TCNT1
	out TIMSK,r24					; για τον timer1.

	sei								; Ενεργοποίησε τις συνολικές διακοπές.

	ldi r24,(1<<CS12)|(0<<CS11)|(1<<CS10)	; CK/1024
	out TCCR1B,r24
	
	ldi r16,0b00000001				; Ορίζουμε το bit(0) της PORTA ως είσοδο.
	out DDRA,r16					; bit(0)-PORTA --> είσοδος
			
	ldi r16,0b11111110				; Ορίζουμε τα υπόλοιπα bit της PORTA ως έξοδο.
	out DDRA,r16					; bit(7-1)-PORTΑ --> έξοδος
	
check:
	sbis PINA,0						;loop μέχρι PA0=1
	rjmp check


	ldi r16,0b00000010			
	out PORTA,r16					; ανάβουμε το PA1

	ldi r24,0xA4					; Αρχικοποίηση του TCNT1... 65536-3*7812.5=42098=A472
	out TCNT1H,r24		
	ldi r24,0x72			
	out TCNT1L,r24					; ...για υπερχείλιση μετά από 3 sec.
		

check1:								;loop μέχρι PA0=0
	sbis PINA,0
	rjmp check
	rjmp check1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ISR0:
	cli								; Clear the global interrupt flag in SREG 
									; so prevent any form of interrupt occurring.
	in r26,SREG						; σώσε το περιεχόμενο του SREG
	push r26
intrloop:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  Start of Debouncing (= Αποσπινθηρισμός) ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 		

	ldi r24,(1 << INTF0)						
	out GIFR,r24					; μηδένισε το bit6 του GIFR

	ldi r24 , low(5)				
	ldi r25 , high(5)				; load r25:r24 with 5		
	rcall wait_msec					; delay  5 ms

	in r24,GIFR
	andi r24, 0x40					;αν το 2oMSB (intf0)
	brne intrloop					;είναι ακόμα 1, loop

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  End of Debouncing (= Αποσπινθηρισμός) ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;		

	ser r24							; set register r24						
	
	ldi r16,0b00000010			
	out PORTA,r16					; ανάβουμε το PA1
	
	ldi r24,0xA4					; Αρχικοποίηση του TCNT1... 65536-3*7812.5=42098=A472
	out TCNT1H,r24		
	ldi r24,0x72			
	out TCNT1L,r24					; ...για υπερχείλιση μετά από 3 sec.
	
	pop r26
	out SREG,r26					; επαναφορά SREG
	
	reti							; Επιστροφή από διακοπή στο κύριο πρόγραμμα

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ISR_TIMER1_OVF:
	in r26,SREG			
	push r26						; Σώσε το περιεχόμενο του SREG.

	ldi r16,0b00000000			
	out PORTA,r16					; Σβήνουμε το LED PA1. 

	pop r26
	out SREG,r26					; επαναφορά SREG

	reti							; Επιστροφή από διακοπή στο κύριο πρόγραμμα.

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

wait_usec:   
	sbiw r24 ,1			; 2 κύκλοι (0.250 μsec)  
	nop           		; 1 κύκλος (0.125 μsec)
	nop          		; 1 κύκλος (0.125 μsec)
	nop           		; 1 κύκλος (0.125 μsec)
	nop           		; 1 κύκλος (0.125 μsec)
	brne wait_usec		; 1 ή 2 κύκλοι (0.125 ή 0.250 μsec)
    ret					; 4 κύκλοι (0.500 μsec)

wait_msec:				;(10) για simulation
   	push r24			; 2 κύκλοι (0.250 μsec)
   	push r25			; 2 κύκλοι
 	ldi r24 , low(998)  ; φόρτωσε τον καταχ.  r25:r24 με 998 (1 κύκλος - 0.125 μsec)
  	ldi r25 , high(998) ; 1 κύκλος (0.125 μsec)
   	rcall wait_usec     ; 3 κύκλοι (0.375 μsec), προκαλεί συνολικά καθυστέρηση 998.375 μsec       
   	pop r25             ; 2 κύκλοι (0.250 μsec)
   	pop r24             ; 2 κύκλοι 
   	sbiw r24 , 1        ; 2 κύκλοι 
   	brne wait_msec      ; 1 ή 2 κύκλοι (0.125 ή 0.250 μsec)
   	ret					; 4 κύκλοι (0.500 μsec)