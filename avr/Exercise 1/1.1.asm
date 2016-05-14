/*
 * 1.1.asm
 *
 *  Created: 6/12/2014 9:08:35 ??
 *   Author: Rafail
 */ 

 .include "m16def.inc"						;δήλωση μικροελεγκτή

.def temp = r16
.def output = r17
.def count = r18							;δηλώσεις καταχωρητών							
.equ delay = 500							;δήλωση σταθεράς

ldi temp,low(ramend)
out spl,temp
ldi temp,high(ramend)						
out sph,temp								;αρχικοποίηση δείκτη στοίβας

clr temp
out DDRB,temp								;η PORTB είσοδος

ser temp
out DDRA,temp								;η PORTA έξοδος

ldi output,0x80								;1000 0000
out PORTA,output							;ανάβουμε το αριστερότερο led
ldi r25,high(delay)
ldi r24,low(delay)							;καθυστέρηση = 500 ms = 0.5 s
rcall wait_msec								;εισαγωγή χρονοκαθυστέρησης

main:
	ldi count,7								;αρχικοποίηση μετρητή ολισθήσεων
	rcall right								;πρώτα κίνηση προς τα δεξιά 
	ldi count,7								;επαναφορά του μετρητή ολισθήσεων
	rcall left								;στη συνέχεια κίνηση προς τα αριστερά
	rjmp main								;επανάληψη για συνεχή λειτουργία
	
left:
	in temp,PINB							;έλεγχος για πάτημα του push button
	sbrc temp,0								;αν δεν είναι πατημένο συνεχίζουμε
	rjmp left								;αλλιώς ξαναελέγχουμε
	lsl output								;ολίσθηση του led προς τα αριστερά
	out PORTA,output						;έξοδος στην PORTA
	ldi r25,high(delay)
	ldi r24,low(delay)						;καθυστέρηση = 500 ms = 0.5 s
	rcall wait_msec							;εισαγωγή χρονοκαθυστέρησης
	dec count								;μείωση μετρητή ολισθήσεων
	brne left								;όσο δεν έχουν συμπληρωθεί 7 ολισθήσεις επανάλαβε
	ret										;αλλιώς επιστροφή στο κύριο πρόγραμμα

right:
	in temp,PINB							;έλεγχος για πάτημα του push button
	sbrc temp,0								;αν δεν είναι πατημένο συνεχίζουμε
	rjmp right								;αλλιώς ξαναέλεγχουμε
	lsr output								;ολίσθηση του led προς τα δεξιά
	out PORTA,output						;έξοδος στην PORTΑ
	ldi r25,high(delay)
	ldi r24,low(delay)						;καθυστέρηση = 500 ms = 0.5 s
	rcall wait_msec							;εισαγωγή χρονοκαθυστέρησης
	dec count								;μείωση μετρητή ολισθήσεων
	brne right								;όσο δεν έχουν συμπληρωθεί 7 ολισθήσεις επανάλαβε
	ret										;αλλιώς επιστροφή στο κύριο πρόγραμμα

wait_usec:   
	sbiw r24 ,1      						; 2 κύκλοι (0.250 μsec)  
	nop           							; 1 κύκλος (0.125 μsec)
	nop          							; 1 κύκλος (0.125 μsec)
	nop           							; 1 κύκλος (0.125 μsec)
	nop           							; 1 κύκλος (0.125 μsec)
	brne wait_usec							; 1 ή 2 κύκλοι (0.125 ή 0.250 μsec)
    ret										; 4 κύκλοι (0.500 μsec)

wait_msec:									
   	push r24								; 2 κύκλοι (0.250 μsec)
   	push r25								; 2 κύκλοι
 	ldi r24 , low(998)      				; φόρτωσε τον καταχ.  r25:r24 με 998 (1 κύκλος - 0.125 μsec)
  	ldi r25 , high(998)     				; 1 κύκλος (0.125 μsec)
   	rcall wait_usec        					; 3 κύκλοι (0.375 μsec), προκαλεί συνολικά καθυστέρηση 998.375 μsec       
   	pop r25               					; 2 κύκλοι (0.250 μsec)
   	pop r24               					; 2 κύκλοι 
   	sbiw r24 , 1          					; 2 κύκλοι 
   	brne wait_msec        					; 1 ή 2 κύκλοι (0.125 ή 0.250 μsec)
   	ret										; 4 κύκλοι (0.500 μsec)
