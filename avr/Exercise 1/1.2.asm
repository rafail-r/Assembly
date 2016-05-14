/*
 * 1.2.asm
 *
 *  Created: 6/12/2014 9:58:11 ??
 *   Author: Rafail
 */ 

 .include "m16def.inc"


ldi r26,low(ramend)
out spl,r26
ldi r26,high(ramend)
out sph,r26				; αρχικοποίηση δείκτη στοίβας

ser r26         		; αρχικοποίηση της PORTA 
out DDRA,r26   			; για έξοδο 

clr r26					
out DDRB,r26			; αρχικοποίηση της PORTB για είσοδο
ldi r26,0b11111111		; ενεργοποίηση pull-up αντιστάσεων στην PORTB
out PORTA,r26


main:	
	rcall on 			; ’ναψε τα LEDs
	rcall off 			; Σβήσε τα LEDs
	rjmp main	  		; Επανάλαβε
						
on:						; Υπορουτίνα για να ανάβουν τα LEDs
	ser r26				; θέσε τη θύρα εξόδου των LEDs
	out PORTA,r26	
	rcall delay_on
	ret					; Γύρισε στο κύριο πρόγραμμα

						
off:					; Υπορουτίνα για να σβήνουν τα LEDs
	clr r26				; μηδένισε τη θύρα εξόδου των LEDs
	out PORTA,r26
	rcall delay_off	
	ret					; Γύρισε στο κύριο πρόγραμμα

delay_on:
	ldi r25,0			
	ldi r24,100			; αρχικοποίηση χρονοκαθυστέρησης στα 100 msec
	in r26, PINB		; διαβάζουμε τα dip switches
	andi r26, 0x0f		; απομόνωση των 4 LSB (για άναμμα)
	breq done			; αν είναι μηδέν καλούμε αμέσως την ρουτίνα wait_msec
add100:					
	adiw r24,50
	adiw r24,50
	dec r26
	brne add100			; αλλιώς πρώτα υπολογίζουμε την καθυστέρηση 
						; [R25:R24 = R26*100 + 100]
done:
	rcall wait_msec
    ret

delay_off:
	ldi r25,0			
	ldi r24,100			; αρχικοποίηση χρονοκαθυστέρησης στα 100 msec
	in r26, PINB		; διαβάζουμε τα dip switches
	andi r26, 0xf0		; απομόνωση των 4 MSB (για σβήσιμο)		
	lsr r26
	lsr r26
	lsr r26
	lsr r26				; 4 shift right
	breq donef			; αν είναι μηδέν καλούμε αμέσως την ρουτίνα wait_msec
add100f:
	adiw r24,50
	adiw r24,50
	dec r26
	brne add100f		; αλλιώς πρώτα υπολογίζουμε την καθυστέρηση 
						; [R25:R24 = R26*100 + 100]
donef:
	rcall wait_msec
    ret

wait_usec:   
	sbiw r24,1      	; 2 κύκλοι (0.250 μsec)  
	nop           		; 1 κύκλος (0.125 μsec)
	nop          		; 1 κύκλος (0.125 μsec)
	nop           		; 1 κύκλος (0.125 μsec)
	nop           		; 1 κύκλος (0.125 μsec)
	brne wait_usec		; 1 ή 2 κύκλοι (0.125 ή 0.250 μsec)
    ret             	; 4 κύκλοι (0.500 μsec)

wait_msec:				; για simulation (10) αντί για (998) και rate=ultimate
   	push r24			; 2 κύκλοι (0.250 μsec)
   	push r25			; 2 κύκλοι
 	ldi r24 , low(998)	; φόρτωσε τον καταχ.  r25:r24 με 998 (1 κύκλος - 0.125 μsec)
  	ldi r25 , high(998)	; 1 κύκλος (0.125 μsec)
   	rcall wait_usec     ; 3 κύκλοι (0.375 μsec), προκαλεί συνολικά καθυστέρηση 998.375 μsec       
   	pop r25             ; 2 κύκλοι (0.250 μsec)
   	pop r24             ; 2 κύκλοι 
   	sbiw r24 , 1        ; 2 κύκλοι 
   	brne wait_msec      ; 1 ή 2 κύκλοι (0.125 ή 0.250 μsec)
   	ret					; 4 κύκλοι (0.500 μsec)
