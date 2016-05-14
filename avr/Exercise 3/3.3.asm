/*
 * 3.3.asm
 *
 *  Created: 23/12/2014 6:24:34 ??
 *   Author: Rafail
 */ 


 .INCLUDE "M16DEF.INC"
.dseg
_tmp_: .byte 2
.cseg
.org 0x0
	rjmp start
START:
	LDI R24, LOW(RAMEND)				;initialize stack pointer
	OUT SPL, R24
	LDI R24, HIGH(RAMEND)
	OUT SPH, R24
	
	SER R24					
	OUT DDRA, R24						;PORTA as output

	LDI R24 ,(1 << PC7) | (1 << PC6) | (1 << PC5) | (1 << PC4)	
	OUT DDRC, R24						;Initialize PORTC half as output, half as input. output 4MSB C
	
	ldi r24,10						
	rcall scan_keypad_rising_edge

LOOP1:
	CLR R24
	OUT PORTA, R24						;PA leds off
	ldi r24,10							
	rcall scan_keypad_rising_edge
	RCALL KEYPAD_TO_ASCII				;Check if 1 was pressed
	CPI R24, '1'
	BRNE LOOP1
LOOP1_1:
	ldi r24,10
	rcall scan_keypad_rising_edge
	RCALL KEYPAD_TO_ASCII				;Check if 1 was pressed again
	CPI R24,0							;Null
	BREQ LOOP1_1	
	CPI R24, '1'
	BRNE LOOP1							;If 1 wasn't pressed then go back to press 1-1

	SER R23								;1-1 was pressed			ldi r20,0b00000000
loopa:
	inc r20
	push r20
	ser r23
	OUT PORTA, R23						;Light all PA leds 
	LDI R24, LOW(200)			
	LDI R25, HIGH(200)
	RCALL WAIT_MSEC						;Delay for 0.2sec
	clr r19
	OUT PORTA, R19						;Light all PA leds 
	LDI R24, LOW(200)			
	LDI R25, HIGH(200)
	RCALL WAIT_MSEC						;Delay for 0.2sec

	cpi r20,0b00001010
	brne loopa
	RJMP LOOP1

		  

WAIT_USEC:
	SBIW R24,1
	NOP
	NOP
	NOP
	NOP
	BRNE WAIT_USEC
	RET

WAIT_MSEC:
	PUSH R24
	PUSH R25
	LDI R24, LOW(998)
	LDI R25, HIGH(998)
	RCALL WAIT_USEC
	POP R25
	POP R24
	SBIW R24,1
	BRNE WAIT_MSEC
	RET

SCAN_ROW:
	LDI R25 ,0X08 
BACK_: 
	LSL R25
	DEC R24 
	BRNE BACK_
	OUT PORTC ,R25 
	NOP
	NOP 
	IN R24 ,PINC 
	ANDI R24 ,0X0F 
	RET 

SCAN_KEYPAD:
	LDI R24 ,0X01 
	RCALL SCAN_ROW
	SWAP R24 
	MOV R27 ,R24 
	LDI R24 ,0X02 
	RCALL SCAN_ROW
	ADD R27 ,R24 
	LDI R24 ,0X03 
	RCALL SCAN_ROW
	SWAP R24 
	MOV R26 ,R24 
	LDI R24 ,0X04
	RCALL SCAN_ROW
	ADD R26 ,R24 
	MOVW R24 ,R26 
	RET
scan_keypad_rising_edge:
	mov r22 ,r24 
	rcall scan_keypad 
	push r24 
	push r25
	mov r24 ,r22 
	ldi r25 ,0 
	rcall wait_msec
	rcall scan_keypad ;
	pop r23 
	pop r22 
	and r24 ,r22
	and r25 ,r23
	ldi r26 ,low(_tmp_) 
	ldi r27 ,high(_tmp_) 
	ld r23 ,X+
	ld r22 ,X
	st X ,r24 
	st -X ,r25
	com r23
	com r22 
	and r24 ,r22
	and r25 ,r23
ret
KEYPAD_TO_ASCII: 
	MOVW R26 ,R24 
	LDI R24 ,'*'
	SBRC R26 ,0
	RET
	LDI R24 ,'0'
	SBRC R26 ,1
	RET
	LDI R24 ,'#'
	SBRC R26 ,2
	RET
	LDI R24 ,'D'
	SBRC R26 ,3 
	RET 
	LDI R24 ,'7'
	SBRC R26 ,4
	RET
	LDI R24 ,'8'
	SBRC R26 ,5
	RET
	LDI R24 ,'9'
	SBRC R26 ,6
	RET
	LDI R24 ,'C'
	SBRC R26 ,7
	RET
	LDI R24 ,'4' 
	SBRC R27 ,0 
	RET
	LDI R24 ,'5'
	SBRC R27 ,1
	RET
	LDI R24 ,'6'
	SBRC R27 ,2
	RET
	LDI R24 ,'B'
	SBRC R27 ,3
	RET
	LDI R24 ,'1'
	SBRC R27 ,4
	RET
	LDI R24 ,'2'
	SBRC R27 ,5
	RET
	LDI R24 ,'3'
	SBRC R27 ,6
	RET
	LDI R24 ,'A'
	SBRC R27 ,7
	RET
	CLR R24
	RET






