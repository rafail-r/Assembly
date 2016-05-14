/*
 * 2.2.asm
 *
 *  Created: 16/12/2014 4:16:14 ??
 *   Author: Rafail
 */ 

.include "m16def.inc"				; δήλωση μικροελεγκτή

.org 0x0							; Η αρχή του κώδικα (reset) πάντα
rjmp reset							; θα δηλώνεται στην δ/ση 0x0.

.org 0x4							; Η εξυπηρέτηση της INT1
rjmp ISR1							; ορίζεται στην δ/ση 0x4.

;****************************************************************************************************;	

reset:	
	ldi r16,low(RAMEND)
	out SPL,r16
	ldi r16,high(RAMEND)
	out SPH,r16						; αρχικοποίηση του δείκτη στοίβας
	
	ser r24							; set register r24						
	out DDRA,r24					; PORTA --> έξοδος
	out DDRC,r24					; PORTC --> έξοδος
	clr r23							; clear register 23
	out DDRB,r23					; PORTB --> είσοδος
		
	ldi r24,(1<<ISC11)|(1<<ISC10)	; Ορίζεται η διακοπή INT1 να
	out MCUCR,r24					; προκαλείται με σήμα θετικής ακμής.
	ldi r24,(1<<INT1)				; Ενεργοποίησε τη διακοπή INT1.
	out GICR,r24
	sei								; Ενεργοποίησε τις συνολικές διακοπές.

	clr r26							; Μηδένισε τον μετρητή του κύριου προγράμματος.
loop:	
	out PORTA,r26					; Δείξε την τιμή του μετρητή κύριου προγράμματος
	ldi r24,low(100)				
	ldi r25,high(100)				; load r25:r24 with 100
	rcall wait_msec					; delay 100 ms
	inc r26							; Αύξησε μετρητή κύριου προγράμματος.
	rjmp loop						; Επανάλαβε.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ISR1:
	intrloop:	
	cli								; Clear the global interrupt flag in SREG 
									; so prevent any form of interrupt occurring.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  Start of Debouncing (= Αποσπινθηρισμός) ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 		

	ldi r24,(1 << INTF1)						
	out GIFR,r24					; μηδένισε το bit7 του GIFR

	ldi r24 , low(5)				
	ldi r25 , high(5)				; load r25:r24 with 5		
	rcall wait_msec					; delay  5 ms

	in r24,GIFR
	andi r24, 0x80					;αν το MSB (intf1)
	brne intrloop					;είναι ακόμα 1, loop

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  End of Debouncing (= Αποσπινθηρισμός) ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
check:
	push r26						; Σώσε το περιεχόμενο των r26 (το μετρητή του κύριου προγράμματος)
	in r26,SREG
	push r26						; και SREG

	clc								;μηδενισμός carry
	clr r23							;r23=0
	ldi r18,0x08					;r18=8
	in r20,PINB						;Διάβασε Β
check1:
	dec r18							;μείωση μετρητή
	ror r20							;κύληση Β δεξιά, με carry
	brcc cont						;αύξηση C, αν carry=1
	inc r23							
cont:
	cpi r18,0x00					;αλλιώς, αν είδαμε όλα τα bits τέλος
	brne check1						;αλλιώς συνέχεια
	out PORTC,r23					;Δείξε την τιμή του μετρητή των Β στο C

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