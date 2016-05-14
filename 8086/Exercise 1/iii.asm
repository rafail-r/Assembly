EXIT MACRO
    MOV AX, 4C00H
    INT 21H
    ENDM

READ MACRO              ; read keyboard
    MOV AH, 8
    INT 21H
    ENDM

PRINT MACRO CHAR        ; ektupwsh char
    MOV DL,CHAR
    MOV AH, 2
    INT 21H
    ENDM

PRINT_STR MACRO STRING  ; ektupwsh sumvoloseiras
    MOV DX,OFFSET STRING    
    MOV AH, 9
    INT 21H
    ENDM

org 100h
    JMP START

STR1 DB "Give up to 16 chars, numbers or spaces : $"  
STR2 DB "Numbers LowerCase UpperCase :            $"
STR3 DB "Sorted numbers :                         $"

START:
    PRINT_STR STR1
    MOV CL, 0           ; Metritis xaraktirwn
    MOV DI ,3000H       ; arxizw na apothikeyw sti mnimi ksekinontas apo 3000H
    CLD                 ; DF=0 ..> sto sb deixnei sthn epomenh thesh mnhmhs
;read kai elegxw ti diavasa
KEEP_READING:
    READ                ; eisodos apto plhktrologio
    CMP AL, '*'         ; an einai *, telos
    JE ENDING
    CMP AL, 0DH         ; an einai enter, paw sthn emfanish twn xarakthrwn
    JE DISPLAY          
    CMP AL, 20H         ; an einai to keno, save
    JE SAVE_SPACE
    CMP AL, 30H         ; an einai mikrotero tou 0 , akiro
    JL KEEP_READING
    CMP AL, 39H         ; an einai mikrotero-iso me to 9, save
    JLE SAVE_CHAR         
    CMP AL, 41H         ; an einai mikrotero tou A, akiro
    JL KEEP_READING
    CMP AL, 5AH         ; an einai mikrotero-iso tou Z, save
    JLE SAVE_CHAR
    CMP AL, 61H         ; an einai mikrotero tou a, akiro
    JL KEEP_READING
    CMP AL, 7AH         ; an einai mikrotero-iso tou z, save
    JLE SAVE_CHAR         

GO:
    CMP CL, 16          ; diavasa 16 xarakthres?
    JNE KEEP_READING    ; an oxi, sunexizw

WAIT_FOR_ENTER:
    READ                ; alliws, perimenw to enter
    CMP AL, 0DH
    JNE WAIT_FOR_ENTER

DISPLAY:
    PRINT 0AH           ; ektupwsh enter
    PRINT 0DH
    PRINT_STR STR2
    MOV SI, 3000H       ; 8a sarwsw th mnhmh prwta anazhtwntas tous ari8mous kai 8a tous tupwsw
    CLD
    MOV BL,CL           ; save CL ( plh8os do8entwn xarakthrwn )
    CMP CL, 0           ; an de do8hkan xarakthres paw sthn arxh
    JE START
                        
; Anazitisi arithmwn sti mnimi
SEARCH_NUM:
    LODSB               ; fortwnw byte apo th mnhmh
    CMP AL, 30H         ; an einai mikroteros apo to 0 , den einai ari8mos
    JL NOT_NUM
    CMP AL, 39H         ; an einai megaluteros apo to 9 , den einai ari8mos
    JG NOT_NUM
    PRINT AL            ; alliws ektupwse ton ari8mo 

NOT_NUM:
    DEC CL              ; meiwnw plh8os
    JNZ SEARCH_NUM      ; an den einai 0 , sunexizw

    MOV DL, 20H         ; emfanizw to space
    PRINT DL            
    MOV SI ,3000H
    CLD
    MOV CL,BL           ; restore CL  
    
; Anazitisi pezwn sti mnimi
SEARCH_LOWER_C:
    LODSB               ; fortwnw byte apo th mnhmh
    CMP AL, 61H         ; elegxw an einai pezos
    JL NOT_LOWER_C      ; an den einai paw sto NOT_LOWER_C
    CMP AL, 7AH
    JG NOT_LOWER_C
    PRINT AL            ; an einai ton ektupwnw
    
NOT_LOWER_C:
    DEC CL              ; meiwnw to plh8os
    JNZ SEARCH_LOWER_C  ; an den einai 0 , sunexizw 

    MOV DL, 20H         ; emfanizw to space
    PRINT DL            
    MOV SI, 3000H       ; 8a sarwsw pali th mnhmh gia na vrw k na emfanisw ta kefalaia
    CLD
    MOV CL,BL           ; restore CL         
    
; Anazitisi kefalaiwn sti mnimi
SEARCH_UPPER_C:
    LODSB               ; fortwnw byte apo th mnhmh
    CMP AL, 41H         ; an den einai kefalaio paw sto NOT_UPPER_C
    JL NOT_UPPER_C
    CMP AL, 5AH
    JG NOT_UPPER_C
    PRINT AL            ; alliws to emfanizw

NOT_UPPER_C:
    DEC CL              ; meiwnw to plh8os
    JNZ SEARCH_UPPER_C  ; an den einai 0 epanalamvanw  
    
    MOV SI, 3000H
    CLD
    MOV CL,BL           ; restore CL 
    PRINT 0AH           ; ektupwnw to enter
    PRINT 0DH
    PRINT_STR STR3                               
    

    MOV DH, 30H         ; psaxnw ta midenika gia arxi
    MOV CH, 10H         ; 10 loops = ena gia kathe arithmo
; Gia kathe arithmo ksexorista, ksekinontas apo to 0. Elegxw an emfanizete sti mnimi 
SORT_NUM:
    LODSB               ; fortwnw byte apo th mnhmh
    CMP AL, DH          ; An den einai afto pou psaxnw  
    JNE NOT_NUM2        ; skip
    PRINT DH            ; alliws ektupwse ton ari8mo 

NOT_NUM2:
    DEC CL              ; meiwnw plh8os
    JNZ SORT_NUM        ; an den einai 0 , sunexizw         
    
    MOV SI, 3000H
    CLD
    MOV CL,BL           ; restore CL
    ADD DH, 1      
    DEC CH
    JNZ SORT_NUM
    
    
    
    PRINT 0AH           ; ektupwnw to enter
    PRINT 0DH
    JMP START           ; epanalamvanw th diadikasia   
    
SAVE_SPACE:
    INC CL              ; diavasa to keno kai au3anw to metrhth xarakthrwn
    stosb
    PRINT AL            ; to emfanizw
    JMP GO              ; epistrofh pisw
SAVE_CHAR:
    INC CL              ; au3anw to metrhth xarakthrwn
    STOSB               ; apo8hkeuw ton xar . sth mnhmh
    PRINT AL            ; ton emfanizw
    JMP GO              ; kai epistrefw
ENDING: 
    EXIT