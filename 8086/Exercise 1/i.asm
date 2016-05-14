PRINT_DIGIT MACRO DIGIT
PUSH AX
PUSH DX
MOV DL, DIGIT
MOV AH, 02H
INT 21H
POP DX
POP AX
ENDM 

PRINT_MSG MACRO MSG
PUSH AX
PUSH DX
LEA DX,MSG
MOV AH, 09H
INT 21H
POP DX
POP AX
ENDM 

READ_DIGIT MACRO
MOV AH, 08H
INT 21H
ENDM 

org 100h 

START:
PRINT_MSG MSG1  ; Print "Give a 9-bit 2's comlement number:"
MOV DL, 0       ; ta 8 LSB tha mpoun ston DL
MOV CX, 9       ; Counter gia 9 loops = 9 diavasmata  
MOV DH, 0       ; Arxikopio to MSB sto 0


READ: 
READ_DIGIT
CMP AL, 'Q'     ; Me Q end
JE END
CMP AL, 'q'     ; Me q end
JE END
CMP AL, 30H     ; An diavasa 0 sinexizw
JL READ
CMP AL, 31H     ; An diavasa 1 sinexizw 
JG READ         ; allios ksanadiavazw
SUB AL, 30H     ; metatropi se Hex
SAL DL, 1       ; slide to proigoumeno psifio aristera, anigo xoro sto LSB oste me prosthesi na mpei to neo
JNC CONT        ; An exo iperxilisi (MSB einai 1) 
MOV DH, 01H     ; To apothikeyw sto DH
CONT:           ; allios sinexizw
ADD DL,AL       ; prosthesi na mpei to neo psifio sto LSB
ADD AL, 30H     ; Metatropi piso se ASCII gia print 
PRINT_DIGIT AL  ; Print to psifio
LOOP READ       ; Loop mexri C=0

PRINT_MSG MSG2  ; Print "Decimal:"
MOV AL,DL       ; AL pernei ta 8 LSB
MOV AH, DH      ; AH pernei to MSB
CMP AH, 00H     ; NOT MSB=0
JE  POSITIVE    ; tote thetikos, den allazw tipota
PRINT_DIGIT '-'
MOV AH, 00H
NOT AL
ADD AX, 01H
JMP BIN_TO_DEC

POSITIVE:
PRINT_DIGIT '+' ; ginete 1 


BIN_TO_DEC:
MOV DX, 0
MOV BX, 10
DIV BX          ; Divide number with 10 , quotient in AX, remainder in DX
INC CX          ; Increase decimal digits
PUSH DX         ; Store in the stack the remainder of the division
CMP AX, 0       ; If quotient = 0 then division ends
JNZ BIN_TO_DEC

OUTPUT:
POP DX
ADD DX, 30H     ; metatropi se ASCII
PRINT_DIGIT DL  ; Print apotelesma
LOOP OUTPUT     ; Loop gia kathe dekadiko psifio (C=plithos)
JMP START

END:
MOV AX, 4C00H
INT 21H
ret 

MSG1 DB 0AH, 0DH, "Give a 9-bit 2's comlement number: $"
MSG2 DB 0AH, 0DH, "Decimal: $"