/*
 * 3.1.asm
 *
 *  Created: 22/12/2014 4:52:16 ??
 *   Author: Rafail
 */ 


.include "m16def.inc"		; δήλωση μικροελεγκτή
.def input=r17
.def temp=r25
.def result=r24

.org 0x0					; Η αρχή του κώδικα (reset) πάντα
rjmp reset					; θα δηλώνεται στην δ/ση 0x0.

reset:
	ldi r26,high(RAMEND)	
	out SPH,r26
	ldi r26,low (RAMEND)
	out SPL,r26				; αρχικοποίηση δείκτη στοίβας

	ser r26					; set register r26		
	out DDRC,r26			; portC --> έξοδος

	clr r26					; clear register r26
	out DDRA,r26			; portA --> είσοδος
	out DDRB,r26			; portB --> είσοδος
	
start:
	in r26,pinB				; Διαβάζουμε τα dip-switches του portB.
	mov input,r26			; Αποθηκεύουμε την είσοδο στον καταχωρητή input.
	
	mov temp,input			; Αποθηκεύουμε την είσοδο στον καταχωρητή temp.
	lsr input				; Τοποθέτηση του bit1 στη κατάλληλη θέση(0) για να γίνει η πράξη με το bit0.				
	eor temp,input			; πύλη 1 XOR					
	andi temp,0x01			; Απομόνωση του bit0
	mov result,temp			; save
	
	mov temp,input			; Επαναφορά
	lsr input				; Τοποθέτηση του bit3 στη κατάλληλη θέση(1) για να γίνει η πράξη με το bit2.
	and temp,input			; πύλη 2 AND
	andi temp,0x02			; Απομόνωση του bit1
	or result,temp			; save

	mov temp,input			; Επαναφορά
	lsr input				; Τοποθέτηση του bit5 στη κατάλληλη θέση(2) για να γίνει η πράξη με το bit4.
	eor temp,input			; πύλη 3 XNOR = (not)xor
	com temp				; not
	andi temp,0x04			; Απομόνωση του bit2
	or result,temp			; save

	mov temp,input			; Επαναφορά
	lsr input				; Τοποθέτηση του bit7 στη κατάλληλη θέση(3) για να γίνει η πράξη με το bit6.
	or temp,input			; πύλη 4 OR
	andi temp,0x08			; Απομόνωση του bit3
	or result,temp			; save

	mov temp,result
	lsr temp
	andi temp,0x04			; Απομόνωση του bit2
	or result,temp			; πύλη 5 OR

	in r26,PINA				; Ανάγνωση ακροδεκτών PORTA
	eor result,r26			; Aν έχει πατηθεί το PAx συμπληρώνεται PCx !
	andi result,0x0F		; Απομόνωση των bit 3..0
	out PORTC,result		; Έξοδος στα LEDs θύρας εξόδου portC.
	rjmp start				; Επανάληψη για συνεχή λειτουργία.