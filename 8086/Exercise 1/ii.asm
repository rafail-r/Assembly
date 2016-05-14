read macro 
    mov ah, 8
    int 21h
endm   

print macro char
    mov dl,char
    mov ah,2
    int 21h
endm

print_str macro string
    lea dx, string
    mov ah,9
    int 21h
endm

data_seg segment
    msg1 db "GIVE 3 HEX DIGITS:$"
    newline db 0ah,0dh, "$"
    msg2 db "DECIMAL=$"
data_seg ends

stack_seg segment stack
    dw   128  dup(0)
stack_seg ends

code_seg segment
    assume cs:code_seg, ds:data_seg
main proc far
    mov ax, data_seg
    mov ds, ax
    mov es, ax  
start: 
    print_str msg1       
    call read_hex         ;Diavasma protou psifiou=0000XXXX
    mov bh,al             ;Save sto BH
    call read_hex         ;Diavasma deyterou psifiou=0000YYYY
    mov bl,al             ;Save sto BL
    call read_hex         ;Diavasma tou tritou psifiou=0000ZZZZ
    mov ch,al             ;save sto CH
    call read_hex_enter   ;Perimenw to Enter
    mov cl,bh             ;Pernw to proto          
    call char_to_hex      ;ASCII->HEX
    mov bh,cl             ;to epistrefo
    mov cl,bl 	          ;pernw to deytero
    call char_to_hex      ;ASCII->HEX
    mov bl,cl             ;to epistrefo
    mov cl,ch		      ;pernw to trito 
    call char_to_hex      ;ASCII->HEX   
    mov ch,cl             ;to epistrefo
    mov cl,4			  ;
    mov ah,bh             ;AH = 0000XXXX			  
    mov al,bl             ;AL = 0000YYYY
    shl al,cl             ;AL = YYYY0000
    add al,ch             ;AL = YYYYZZZZ => AX = 0000XXXX YYYYZZZZ
    mov dx,0              ;
    mov cx,1000           ;
    div cx                ;AX/1000
    mov bl,al             ;To piliko(xiliades) mpenei sto BL
    mov ax,dx             ;to ipolipo(ekatontades+dekades+monades) sto AX
    mov cl,100            
    div cl                ;AX/100 (to ipolipo dekades+monades sto AH)
    mov bh,al             ;To piliko(ekatontades) mpenei sto BH
    mov al,0              ;AL = 00000000
    xchg al,ah            ;AX = 00000000 <Ypolipo pou itan sto AH>
    mov cl,10             
    div cl                ;AX/10
    mov cl,al             ;To piliko(dekades) sto CL
    mov ch,ah             ;To ipolipo(monades) sto CH
    add bl,'0'            ;DEC->ASCII
    add bh,'0'            ;DEC->ASCII
    add cl,'0'            ;DEC->ASCII
    add ch,'0'            ;DEC->ASCII
    print_str newline     
    print_str msg2
          
    CMP bl,30h
    JE skip
    print bl
    print ','
skip:
    print bh
    print cl
    print ch              ;Εκτύπωση δεκαδικών ψηφίων	
    print_str newline     ;Εκτύπωση νέας γραμμής
    jmp start             
main endp
                     
read_hex proc near          ;An 0-9 A-F a-f print
    input:                  ;An T t exit
        read                ;Allios ignore
        cmp al,'T'          
        jz exit           
        cmp al,'t'       
        jz exit
        cmp al,'0'
        jl input
        cmp al,'9'
        jle continue
        cmp al,'A'
        jl input
        cmp al,'F'
		jle continue
		cmp al,'a'
		jl input
		cmp al,'f'
		jle continue
        jmp input
    continue:
        print al
    ret
    exit:
        mov ax,4c00h   
        int 21h 
read_hex endp 

read_hex_enter proc near    ;idia me tin read_hex alla stamataei sto enter 
input1:                 
    read                
    cmp al,0dh              ;an ENTER return         
    jz return
    cmp al,'T'
    jz exit1 
    cmp al,'t'
    jz exit1
    cmp al,'0'
    jl input1
    cmp al,'9'
    jle continue1
    cmp al,'A'
    jl input1
	cmp al,'F'
	jle continue1
	cmp al,'a'
	jl input1
	cmp al,'f'
	jle continue1   
    jmp input1
continue1:
    print al
    jmp input1
return: 
    ret
exit1:
    mov ax,4c00h
    int 21h 
read_hex_enter endp  

char_to_hex proc near       ;an 0-9 -30, an A-F  -37, an a-f  -57.   
    cmp cl,'9'
    jle addr1
    cmp cl,'F'
	jle addr2
	sub cl,57h
    jmp addr3
addr1:
    sub cl,'0'
	jmp addr3
addr2: 
    sub cl,37h
addr3:
	ret
char_to_hex endp

code_seg ends

end main 