/*
 * 2.1.asm
 *
 *  Created: 16/12/2014 1:43:26 ??
 *   Author: Rafail
 */ 


 .include "m16def.inc"				; δήλωση μικροελεγκτή

.org 0x0							; Η αρχή του κώδικα (reset) πάντα
rjmp reset							; θα δηλώνεται στην δ/ση 0x0.

.org 0x2							; Η εξυπηρέτηση της INT0
rjmp ISR0							; ορίζεται στην δ/ση 0x2.

;****************************************************************************************************;	

reset:	
	ldi r16,low(RAMEND)
	out SPL,r16
	ldi r16,high(RAMEND)
	out SPH,r16						; αρχικοποίηση του δείκτη στοίβας

	ser r24							; set register r24						
	out DDRA,r24					; PORTA --> έξοδος
	out DDRB,r24					; PORTB --> έξοδος
	clr r23							; Μηδενισμός του μετρητή των εξωτερικών διακοπών.
		
	ldi r24,(1<<ISC01)|(0<<ISC00)	; Ορίζεται η διακοπή INT0 να
	out MCUCR,r24					; προκαλείται με σήμα αρνητικής ακμής.
	ldi r24,(1<<INT0)				; Ενεργοποίησε τη διακοπή INT0.
	out GICR,r24
	sei								; Ενεργοποίησε τις συνολικές διακοπές.

	clr r26							; Μηδένισε τον μετρητή του κύριου προγράμματος.
loop:	
	out PORTA,r26					; Δείξε την τιμή του μετρητή κύριου προγράμματος
									; στα LEDs της θύρας εξόδου PORTB.
	ldi r24,low(100)				
	ldi r25,high(100)				; load r25:r24 with 200
	rcall wait_msec					; delay 100 ms
	inc r26							; Αύξησε μετρητή κύριου προγράμματος.
	rjmp loop						; Επανάλαβε.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ISR0:	
	intrloop:
	cli								; Clear the global interrupt flag in SREG 
									; so prevent any form of interrupt occurring.
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
	push r26						; Σώσε το περιεχόμενο των r26 (το μετρητή του κύριου προγράμματος)
	in r26,SREG
	push r26						; και SREG
check:	
	clr r22							; clear register r22
	out DDRD,r22					; PORTD --> είσοδος
	in r19,PIND
	andi r19,0x01
	cpi r19,0x00
	brne return
	inc r23							; ’ύξησε μετρητή εξωτερικών διακοπών. 
	out PORTB,r23					; Δείξε την τιμή του μετρητή διακοπών
									; στα LEDs της θύρας εξόδου PORTΒ.
return:	
	pop r26							
	out SREG,r26
	pop r26							; Επαναφορά καταχωρητών r26 και SREG.
	sei								; Ενεργοποίηση της σημαίας διακοπών του καταχωρητή κατάστασης.
	reti							; Interrupt Return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

wait_usec:   
	sbiw r24 ,1      				; 2 κύκλοι (0.250 μsec)  
	nop           					; 1 κύκλος (0.125 μsec)
	nop          					; 1 κύκλος (0.125 μsec)
	nop           					; 1 κύκλος (0.125 μsec)
	nop           					; 1 κύκλος (0.125 μsec)
	brne wait_usec					; 1 ή 2 κύκλοι (0.125 ή 0.250 μsec)
    ret								; 4 κύκλοι (0.500 μsec)

wait_msec:							; (10)  για simulation
   	push r24						; 2 κύκλοι (0.250 μsec)
   	push r25						; 2 κύκλοι
 	ldi r24 , low(998)    			; φόρτωσε τον καταχ.  r25:r24 με 998 (1 κύκλος - 0.125 μsec)
  	ldi r25 , high(998)     		; 1 κύκλος (0.125 μsec)
   	rcall wait_usec        			; 3 κύκλοι (0.375 μsec), προκαλεί συνολικά καθυστέρηση 998.375 μsec       
   	pop r25               			; 2 κύκλοι (0.250 μsec)
   	pop r24               			; 2 κύκλοι 
   	sbiw r24 , 1        			; 2 κύκλοι 
   	brne wait_msec      			; 1 ή 2 κύκλοι (0.125 ή 0.250 μsec)
   	ret								; 4 κύκλοι (0.500 μsec)