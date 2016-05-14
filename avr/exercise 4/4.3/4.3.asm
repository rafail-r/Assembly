/*
 * 4.3.asm
 *
 *  Created: 20/1/2015 9:00:44 ??
 *   Author: Rafail
 */ 

 .include "m16def.inc"

RESET:
		
	ldi r24 , low(RAMEND) ; initialize stack pointer
	out SPL , r24
	ldi r24 , high(RAMEND)
	out SPH , r24
	
	ser r28
    out DDRD, r28	     ; port D as output
    clr r28		
	out DDRA, r28	     ; port A as input


	rcall lcd_init
    
    ldi r24 ,low(100)
	ldi r25 ,high(100)
	rcall wait_usec
loop:	
	ldi r29,0x64
	ldi r30,0x0a
	ldi r19,0x30
	



	ldi r24,2
	rcall lcd_command
	ldi r24 ,low(1580)  //go to address 00
	ldi r25 ,high(1580)
	rcall wait_usec


	ldi r17,0xff
	ldi r18,0xff
	in r28,PINA
	mov r27,r28     ;backup
	andi r28,0x80
	cpi r28,0x80    ;check MSB
	breq negative	;MSB=1 => NEGATIVE
	jmp positive	;MSB=0 => POSITIVE

negative:
	ldi r16,'-'
	mov r28,r27		;restore apo backup r28
	com r28			;not(input)
	jmp count		;go COUNT

positive:
	ldi r16,'+'
	mov r28,r27				
	jmp count

count:

ekatontades: 		
	inc r17			
	subi r28,0x64			;input-100
	brcc ekatontades		;kathe 0niko carry = +1 ekatontada
	add r28,r29

decades:		
	inc r18			;dekades
	subi r28,0x0A
	brcc decades
	add r28,r30
	mov r26,r28

	in r27,PINA
	mov r28,r27
	andi r28,0x80
	lsr r28
	lsr r28
	lsr r28
	lsr r28
	lsr r28
	lsr r28
	lsr r28
	add r28,r19
	mov r24,r28
	rcall lcd_data

	mov r28,r27
	andi r28,0x40
	lsr r28
	lsr r28
	lsr r28
	lsr r28
	lsr r28
	lsr r28
	add r28,r19
	mov r24,r28
	rcall lcd_data

	mov r28,r27
	andi r28,0x20
	lsr r28
	lsr r28
	lsr r28
	lsr r28
	lsr r28
	add r28,r19
	mov r24,r28
	rcall lcd_data

	mov r28,r27
	andi r28,0x10
	lsr r28
	lsr r28
	lsr r28
	lsr r28
	mov r24,r28
	rcall lcd_data

	mov r28,r27
	andi r28,0x08
	lsr r28
	lsr r28
	lsr r28
	add r28,r19
	mov r24,r28
	rcall lcd_data

	mov r28,r27
	andi r28,0x04
	lsr r28
	lsr r28
	add r28,r19
	mov r24,r28
	rcall lcd_data

	mov r28,r27
	andi r28,0x02
	lsr r28
	add r28,r19
	mov r24,r28
	rcall lcd_data

	mov r28,r27
	andi r28,0x01
	add r28,r19
	mov r24,r28
	rcall lcd_data

	ldi r24,'='
	rcall lcd_data
	
	mov r24,r16     //+,-
	rcall lcd_data

	cpi r17,0x00
	breq dio
	add r17,r19
	mov r24,r17     //x00
	rcall lcd_data

dio:
	cpi r18,0x00
	breq ena
	add r18,r19
	mov r24,r18     //0x0
	rcall lcd_data
	
ena:
    add r26,r19
	mov r24,r26     //00x
	rcall lcd_data
	
	clr r26
	cpse r17,r26
	jmp cont
	ldi r24,' '     //keno
	rcall lcd_data

	cpse r18,r26
	jmp cont
	ldi r24,' '     //keno
	rcall lcd_data
	
cont:
	ldi r24 ,low(1000)
	ldi r25 ,high(100)
	rcall wait_msec
	
	
	clr r19
	clr r24
	clr r26
	jmp loop
	


.include "wait.asm"
.include "lcd.asm"
