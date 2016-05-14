EXIT MACRO
    MOV AX, 4C00H
    INT 21H
ENDM

READ MACRO                       ; anagnwsh xarakthra
     MOV AH, 8
    INT 21H
ENDM 

PRINT MACRO CHAR                 ; ektupwsh char
    MOV DL,CHAR         
    MOV AH, 2
    INT 21H
ENDM

PRINT_STR MACRO STRING           ; ektupwsh sumboloseiras
    MOV DX,OFFSET STRING
    MOV AH, 9
    INT 21H
ENDM

org 100h
JMP START

STR1 DB "1st number: $"       ; orismos sumvoloseirwn
STR2 DB "2nd number: $"
STR3 DB "Result: $"

START: 
    PRINT 0AH
    PRINT 0DH
    PRINT 0AH
    PRINT_STR STR1
    MOV DI ,3000H               ; o prwtos arithmos sthn 3000H
    CLD                         ; mhdenizei ti simaia DF wste me D+=1 
    CALL MAKE_NUM               ; diabazei arithmo ton swzei sth mnhmh
    MOV DI ,2000H               ; deuteros  arithmos sthn 2000H
    CLD
    PRINT 0AH
    PRINT 0DH                   ; newline
    PRINT_STR STR2
    CALL MAKE_NUM               ; diabazei ton deutero arithmo kai ton swzei
    PRINT 0AH                   ; newline
    PRINT 0DH

                    ; x0 * y0 
    MOV SI ,3000H
    CLD
    LODSW
    LODSW
    MOV BX,AX                   ; o BX exei ton x0
    MOV SI ,2000H
    CLD
    LODSW
    LODSW                       ; o AX exei ton y0
    MUL BX                      ; x0*y0 , apotelesma stous AX, DX
    CLC                         ; mhdenismos shmaias kratoumenou
    MOV DI ,2500H               ; apo8hkeush tou AX sth mnhmh(2500H) giati ta 16 teleutaia
    CLD                         ; tou apotelesmatos einai etoima
    STOSW
    MOV BX,DX                   ; o BX exei twra to periexomeno tou DX apo proigoumeno polloaplasiasmo
    MOV BP, 0                   ; ston kataxwrhth BP tha swsw to plhthos twn kratoumenwn , wste na ta
                                ; prosthesw meta pou tha xreiastoun

                    ; x1 * y0                             
    MOV SI ,3000H
    CLD
    LODSW
    MOV CX,AX                   ; o CX exei ton x1
    MOV SI ,2000H
    CLD
    LODSW
    LODSW                       ; o AX exei ton y0
    MUL CX                      ; x1*y0 , to apotelesma stous DX,AX
    CLC                         ; mhdenismos shmaias kratoumenou
    MOV CX,DX                   ; krataw ston CX ta 16 prwta bit gia meta
    ADD BX,AX                   ; pros8etw ta 16 teleutaia bit  me ta 16 pou eixa kratisei ap ton
                                ; prohgoumeno pol /smo , to apotelesma ston BX
    ADC BP, 0                   ; pros8etw to kratoumeno ston BP

                    ;x0 * y1
    MOV SI ,3000H
    CLD
    LODSW
    LODSW
    MOV DX,AX                   ; o DX exei ton x0
    MOV SI ,2000H
    CLD
    LODSW                       ; o AX exei ton y1
    MUL DX                      ; x0*y1 , to apotelesma stous DX,AX
    CLC                         ; mhdenismos shmaias kratoumenou
    ADD AX,BX                   ; pros8etw sta 16 teleutaia bit to a8roisma pou eixa kratisei ston ADC BP, 0 ; pros8etw ston BP to kratoumeno pou isws proekupse
    ADC BP,0
    ADD AX,BP
    MOV DI ,2502H               ; tha swsw ton AX sth mnhmh dioti einai ta epomena 16 bit tou apotelesmatos
    CLD                         ; einai etoima
    STOSW
    ADD CX,BP                   ; pros8wtw ston CX ta kratoumena apo prin
    MOV BP, 0                   ; mhdenizw ton kataxwrhth kratoumenwn gia na swsw ta nea kratoumena
    ADC BP, 0                   ; an proekupse kratoumeno ap thn pros8esh prin , to swzw
    ADD CX,DX                   ; athroizw CX kai DX (16 pio shmantika bit ) apo tous pol /smous prin
    ADC BP, 0                   ; kai enhmerwnw ton kataxwrhth kratoumenwn

                    ; x1 * y1                                         
    MOV SI ,3000H
    CLD
    LODSW
    MOV BX,AX                   ; ston BX o x1
    MOV SI ,2000H
    CLD
    LODSW                       ; sto AX o Y1
    MUL BX                      ; x1*y1 , to apotelesma stous DX,AX
    STC                         ; mhdenismos shmaias kratoumenwn
    ADD AX,CX                   ; pros8esh twn 16 lsb me to a8roisma pou eixa prin
    ADC BP, 0                   ; enhmerwsh tou kataxwrhth kratoumenwn
    MOV DI ,2504h               ; swzw sth mnhmh ta epomena 16 bit tou apotelesmatos
    CLD
    STOSW
    ADC DX,BP                   ; prosthetw staa 16 msb ta kratoumena pou pi8anws eixa apo
    MOV AX,DX                   ; tis prohgoumenes prostheseis kai to swzw sth mnhmh
    STOSW

                    ;EKTUPWSH
    PRINT_STR STR3
    MOV SI ,2506H               ; 3ekinw ap to msb
    STD                         ; kai kathe fora me to lodsw 8a katevainw thesh mnhmhs
    MOV BL, 4                   ; 4 fores i diadikasia
    MYLOOP1:
    LODSW
    MOV DL,AH                   ; ektupwsh tou AH me 2 hex psifia
    AND DL, 0F0H                ; apomonwse ta 4 pio shmantika bit tou ari8mou
    MOV CL, 4                   ; olisthisi stis 4 ligotero simantikes theseis
    RCR DL,CL
    CMP BL, 4
    JE OT
    CALL PRINT_HEX
    OT:                            ; ektupwsh hex
    MOV DL,AH                   ; apomonwse kai tupwse ws hex ta 4 ligotero
    AND DL, 0FH                 ; shmantika bits
    CALL PRINT_HEX
    MOV DL,AL                   ; ektupwsh tou AL me 2 hex pshfia
    AND DL, 0F0H
    MOV CL, 4
    RCR DL,CL
    CALL PRINT_HEX
    MOV DL,AL
    AND DL, 0FH
    CALL PRINT_HEX
    DEC BL
    JNZ MYLOOP1 
    JMP START
END1: EXIT 
           
           
           
           
           
           
HEX_KEYB PROC NEAR              ; eisodos hex apo pliktrologio
    PUSH DX                 
IGNORE: 
    READ
    CMP AL, 30H
    JL IGNORE
    CMP AL, 39H
    JG ADDR1
    PUSH AX
    PRINT AL
        POP AX
    SUB AL, 30H
    JMP ADDR2
    ADDR1: 
    CMP AL, 'A'
    JL IGNORE
    CMP AL, 'F'
    JG IGNORE
    PUSH AX
    PRINT AL
    POP AX
    SUB AL, 37H
    JMP ADDR2
ADDR2: 
    POP DX
    RET
HEX_KEYB ENDP 




PRINT_HEX PROC NEAR              ; ektupwsh hex ari8mou
    PUSH AX
    CMP DL, 9
    JG ET1
    ADD DL, 30H
    JMP ET2
ET1: ADD DL, 37H
ET2: PRINT DL
    POP AX
    RET
PRINT_HEX ENDP    




MAKE_NUM PROC NEAR
    MOV CL, 0           ; loop counter
NUM_LOOP: 
    CALL HEX_KEYB        ; diabazei hex
    RCL AL, 4
    MOV BL,AL           ; olisthisi 4 thesewn aristera kai apothikeusi ston BL    BL = XXXX 0000
    CALL HEX_KEYB       ; read hex
    ADD BL,AL           ; prosthesh tou neou me ton BL( to apotelesma ston BL)
    CALL HEX_KEYB       ; read hex                                                BL = XXXX YYYY
    RCL AL, 4
    MOV CH,AL           ; olisthisi 4 theewn kai apothikeusi ston CL              CH = ZZZZ 0000
    CALL HEX_KEYB       ; read hex 
    ADD CH,AL           ; prosthwsi tou neou me ton CH                            CH = ZZZZ WWWW
    MOV AL,CH                                                                     
    STOSB               ; apo8hkeush tou CH prwta sth mnhmh
    MOV AL,BL
    STOSB               ; kai meta tou BL
    INC CL              ; au3anw to metrhth
    CMP CL, 2           ; epanalipsi 2 fores gia 30 psifia
    JNZ NUM_LOOP
    RET
MAKE_NUM ENDP          