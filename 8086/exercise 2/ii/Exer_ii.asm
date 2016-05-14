INCLUDE "MACROS.txt"

org 100h 

.data
    new_line DB 0Dh,0Ah,"$"
    echo_mode DB "CHOOSE ECHO MODE: <1> FOR ECHO ON OR <0> FOR ECHO OFF $"
    br DB 0Ah,0Dh,"CHOOSE BAUD RATE: <1> FOR 300 <2> FOR 600 <3> FOR 1200 <4> FOR <5> FOR 4800 OR <6> FOR 9600 $"
    loc DB "LOCAL $"
    rem DB "REMOTE $"
    divline DB 08,80 DUP (0C4h),"$"
    em DB ?       ;echo mode
    tmp DB ?
    linloc DB 00h ;metavliti grammis topikis othonis
    colloc DB 0Bh ;metavliti stilis topikis othonis
    linrem DB 0Dh ;metavliti grammis apomakrismenis othonis
    colrem DB 0Bh ;metavliti stilis apomakrismenis othonis
    
    
.code
main PROC FAR

    PRINT_STR echo_mode
    PRINT_STR new_line
R1: 
    READ                ;diavazoume to echo mode
    PRINT_STR new_line
    cmp AL,030h         ;an den einai oute 1 oute 0, ksanadiavazoume
    je VALID1
    cmp AL,031h
    jne R1    
VALID1: 
    mov em,AL
    PRINT_STR br
    PRINT_STR new_line
R2: 
    READ                ;diavazoume to baud rate
    PRINT_STR new_line
    cmp AL,031h         ;an den einai apo 1 mexri 6, ksanadiavazoume
    jl R2
    cmp AL,036h
    jle VALID2
    jmp R2
VALID2: 
    sub AL,30h

    or AL,03h

    call OPEN_RS232     ;arxikopoioume tis parametrous ths seiriakis epikoinwnias

    mov AH,00h
    mov AL,2
    int 10h    ;thetoume to mode ths othonis se 80X25 B/W text CGA-EGA
    
    mov AH,02h ;orizoume diakopi poy topothetei to dromea se sigkekrimeni thesi
    mov DH,00h ;thetoume arithmo grammis dromea
    mov DL,01h ;thetoume arithmo stilis dromea
    mov BH,00h ;thetoume arithmo selidas dromea
    int 10h
    PRINT_STR loc     ;tipwnoume to LOCAL panw aristera sthn othoni mas
    
    mov AH,02h
    mov DH,0Ch
    mov DL,01h
    mov BH,00h
    int 10h
    PRINT_STR divline ;tipwnoume th diaxwristikh grammh sto meso ths othonis
    
    mov AH,02h
    mov DH,0Dh
    mov DL,01h
    mov BH,00h
    int 10h
    PRINT_STR rem     ;tipwnoyme to REMOTE amesws meta th diaxwristikh grammh
                      ;sto aristero meros ths othonis

RX: 
    call RXCH_RS232 ;kaloume th routina pou diavazei ton xarakthra pou lamvanoume
    cmp AL,0h       ;an den exei erthei xarakthras pame na elegksoume tin topiki eisodo
    je CHK
    mov AH,02h      ;alliws topothetoume ton kersora sto swsto simeio stin apomakrismeni otho
    mov DH,linrem   ;gia na grapsoume ton xarakthra pou irthe
    mov DL,colrem
    mov BH,00h
    int 10h
    cmp AL,0Dh      ;an o xarakthras pou irthe einai to ENTER tote pame sto REM_ENTER
    
    je REM_ENTER
    cmp AL,08h      ;an einai to BSPACEACE tote pame sthn macro BSPACE
    jne NEXT4   
    BSPACE
NEXT4: 
    PRINT AL     ;alliws ton tipwnoume
    mov AH,03H
    mov BH,00H
    int 10h
    cmp DL,4Fh   ;an den exoume ftasei sto telos grammhs, enhmerwnoume tis metavlitesem,colrem
    jne UPDRC    ;sxetika me ti nea thesi tou dromea

REM_ENTER: 
    inc DH        ;an erthei ENTER h an ftasoume sto telos ths grammhs tote auksanoumeetriti grammwn
    cmp DH,19h    ;tis apomakrismenis othonis kai elegxoume an exoume ftasei sthn teleutaiami
    jne NOSCROLL1 ;an oxi, tote den kanoume SCROLL
    mov AH,06h    ;alliws thetoume tis katalliles parametrous sthn diakoph INT10/06 gia naume to
    mov AL,01h    ;SCROLL
    mov CH,0Dh
    mov CL,0Bh
    mov DH,18h
    mov DL,4Fh
    mov BH,07h
    int 10h
    mov linrem,18h ;eimaste pleon stin teleutaia grammi tis apomakrismenis othonis (REMOTE>tha meinoume ekei
    mov colrem,0Bh ;enimerwnoume kai ti metavliti stilis oti eimaste sthn arxh (exoume orisei ws th sthlh 0Bh)
    jmp CHK        ;pame na elegksoume tin topiki eisodo
    
UPDRC: 
    cmp DL,0Bh     ;an eimaste pio pisw apo auto pou exoume orisei ws arxiki stili, pame sto 0Bh
    jge NEXT5
    mov DL,0Bh
NEXT5: 
    mov linrem,DH  ;kai enimerwnoume tis metavlites tis apomakrismenis othonis gia th neah tou dromea
    mov colrem,DL
    jmp CHK        ;pame na elegksoume tin topiki eisodo
                
NOSCROLL1: 
    mov linrem,DH  ;enimerwnoume ti metavliti grammis kai thetoume arxiki timi stivliti stilis
    mov colrem,0Bh


CHK: 
    mov AH,06h  ;elegxoume an exei paththei kapoio pliktro, alla den kanoume wait gia na min
    mov DL,0FFh ;kollisei ekei to programma se periptwsi pou den patithei pliktro
    int 21h
    jz RX       ;an den exei patithei pliktro pame pisw na lavoume dedomena
    cmp AL,14h  ;alliws elegxoume an to pliktro pou patithike einai sindiasmos
    je QUIT     ;ctrl+T, pou exoume thesei ws sindiasmo eksodou sto DOS
    mov BL,em   ;an oxi, tote fernoume ston BL to echo mode
    cmp BL,0    ;kai an einai 0 tote pame na steiloume to xarakthra xwris
    je TX       ;na ton tipwsoume
    mov tmp,AL  ;alliws apothikeuoume thn timi pou lavame sto temp
    
    mov AH,02h    ;vazoume ton dromea stin katallili thesi gia na tipwsoume stin
    mov DH,linloc ;topiki othoni (LOCAL)
    mov DL,colloc
    mov BH,00h
    int 10h
    cmp AL,0Dh    ;elegxoume an o pros ektipwsh xarakthras einai to ENTER
    je LOC_ENTER  ;an einai tote pame sto LOC_ENTER
    cmp AL,08h    ;alliws elegxoume an einai to BSPACEACE
    jne NEXT3     ;an einai, tote pame sthn macro BSPACE
    BSPACE
NEXT3: 
    PRINT AL   ;alliws ton tipwnoume
    mov AH,03H
    mov BH,00H
    int 10h
    cmp DL,4Fh ;an den exoume ftasei sto telos grammhs, enhmerwnoume tis metavlites
    jne UPDLC  ;sxetika me ti nea thesi tou dromea
    
LOC_ENTER: 
    inc DH          ;an erthei ENTER h an ftasoume sto telos ths grammhs tote auksanoume etriti grammwn
    cmp DH,0Ch      ;tis topikis othonis kai elegxoume an exoume ftasei sthn teleutaia grammi
    jne NOSCROLL2   ;an oxi, tote den kanoume SCROLL
    mov AH,06h      ;alliws thetoume tis katalliles parametrous sthn diakoph INT10/06 gia n
    mov AL,01h      ;SCROLL
    mov CH,00h
    mov CL,0Bh
    mov DH,0Bh
    mov DL,4Fh
    mov BH,07h
    int 10h
    mov linloc,0Bh  ;eimaste pleon stin teleutaia grammi tis topikis othonis (LOCAL> kai tha
    mov colloc,0Bh  ;enimerwnoume kai ti metavliti stilis oti eimaste sthn arxh (exoume orisei ws
    jmp NEXT        ;pame na epanaferoume to xarakthra ston AL gia na ton steiloume
    
UPDLC: 
    cmp DL,0Bh      ;an eimaste pio pisw apo auto pou exoume orisei ws arxiki stili, pame sto 0Bh
    jge NEXT2
    mov DL,0Bh
NEXT2: 
    mov linloc,DH   ;kai enimerwnoume tis metavlites tis topikis othonis gia th nea thesh to
    mov colloc,DL
    jmp NEXT        ;pame na epanaferoume to xarakthra ston AL gia na ton steiloume
    
NOSCROLL2: 
    mov linloc,DH   ;enimerwnoume ti metavliti grammis kai thetoume arxiki timi sti
    mov colloc,0Bh

NEXT: 
    mov AL,tmp      ;epanaferoume to xarakthra ston AL gia na ton steiloume

TX: 
    call TXCH_RS232 ;kaloume th routina pou stelnei to xarakthra pou pliktrologisame
    jmp RX          ;pame na elegksoume an exei erthei allos xarakthras
    
QUIT: 
    exit

main ENDP



OPEN_RS232 PROC NEAR
    JMP START
    BAUD_RATE LABEL WORD
    DW 1047
    DW 768
    DW 384
    DW 192
    DW 96
    DW 48
    DW 24
    DW 12
START: 
    STI
    MOV AH,AL
    MOV DX,03FBH
    MOV AL,80H
    OUT DX,AL
    MOV DL,AH
    MOV CL,4
    ROL DL,CL
    AND DX,0EH
    MOV DI,OFFSET BAUD_RATE
    ADD DI,DX
    MOV DX,03F9H
    MOV AL,CS:[DI]+1
    OUT DX,AL
    MOV DX,03F8H
    MOV AL,CS:[DI]
    OUT DX,AL
    MOV DX,03FBH
    MOV AL,AH
    AND AL,01FH
    OUT DX,AL
    MOV DX,03F9H
    MOV AL,0H
    OUT DX,AL
    RET
OPEN_RS232 ENDP
  
  
RXCH_RS232 PROC NEAR
    MOV DX,3FDh
    IN AL,DX
    TEST AL,1
    JZ NOTHING
    SUB DX,5
    IN AL,DX
    JMP EX2

NOTHING: 
    MOV AL,0
EX2: 
    RET
RXCH_RS232 ENDP


TXCH_RS232 PROC NEAR
    PUSH AX
    MOV DX,03FDh

TXCH_RS232_2: 
    IN AL,DX
    TEST AL,020h
    JZ TXCH_RS232_2
    SUB DX,5
    POP AX
    OUT DX,AL
    RET
TXCH_RS232 ENDP