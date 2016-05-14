include macros
public read_number
public print_hex
public read_number2
public result

stack_seg segment stack
	dw 50 dup (?)
stack_seg ends

code_seg segment
	assume cs:code_seg, ss:stack_seg
read_number proc far			;η ρουτίνα διαβάζει τον πρώτο αριθμό από το πληκτρολόγιο
	mov cl,0					;μηδενισμός μετρητή ψηφίων 
	mov bx,0					;αρχικοποιούμε στο 0 τον αριθμό που θα σχηματιστεί
start0:
	read						;ανάγνωση χαρακτήρα
	cmp al,'Q'	
	je quit0
	cmp al,'q'
	je quit0					;αν δοθεί πλήκτρο εξόδου τερματισμός
	cmp al,'0'
	jl start0
	cmp al,'9'
	jg start0					;έλεγχος για ψηφίο (0-9)
	print al					;εκτύπωση χαρακτήρα
	sub al,'0'					;μετατροπή σε δυαδικό αριθμό
	char_dec					;σχηματισμός του πρώτου αριθμού
								;(σε δυαδική μορφή)	
	inc cl						;αύξηση μετρητή ψηφίων
start1:
	read						;ανάγνωση χαρακτήρα 
	cmp al,'Q'
	je quit0
	cmp al,'q'
	je quit0					;αν δοθεί πλήκτρο εξόδου τερματισμός
	cmp al,'+'					
	je return0
	cmp al,'-'
	je return0					;αν δοθεί σύμβολο πράξης (+/-) επιστροφή
	cmp al,'0'					;αλλιώς έλεγχος για επιπλέον ψηφία
	jl start1
	cmp al,'9'
	jg start1
	print al					;εκτύπωση χαρακτήρα
	sub al,'0'					;μετατροπή σε δυαδικό αριθμό
	char_dec					;σχηματισμός του πρώτου αριθμού       
	inc cl						;αύξηση μετρητή ψηφίων
	cmp cl,4					;αν έχουν δοθεί 4 ψηφία
	je oper						;περιμένουμε σύμβολο πράξης
	jmp start1					;αλλιώς επανάληψη
oper:
	read						;ανάγνωση χαρακτήρα
	cmp al,'Q'
	je quit0
	cmp al,'q'
	je quit0					;αν δοθεί πλήκτρο εξόδου τερματισμός
	cmp al,'+'
	je return0			
	cmp al,'-'		
	je return0					;αν δοθεί σύμβολο πράξης (+/-) επιστροφή
	jmp oper					;περιμένουμε μέχρι να δοθεί σύμβολο πράξης
return0:
	mov ch,al					;αποθήκευση συμβόλου πράξης
	print al					;και εκτύπωσή του
	ret							;επιστροφή στο κύριο πρόγραμμα
quit0:
	exit						
read_number endp

print_hex proc far 
        cmp al,0               ;Όσο δεν έχουμε βρει το πρώτο μη μηδενικό ψηφίο
							   ;δεν τυπώνουμε
        je done 			   ;Η ρουτίνα αυτή μετατρέπει ένα δεκαεξαδικό ψηφίο
        cmp bl,9               ;(δηλ. έναν δυαδικό αριθμό των 4 bit) στον αντίστοιχο
        jle addr4              ;χαρακτήρα και τον τυπώνει στην οθόνη
        add bl,37h
        jmp addr5
        addr4:
            add bl,'0'
        addr5: 
            print bl
		done:
			ret
print_hex endp

read_number2 proc far			;η ρουτίνα διαβάζει τον δεύτερο αριθμό από το πληκτρολόγιο
	mov cl,0					;μηδενισμός μετρητή ψηφίων
	mov bx,0					;αρχικοποιούμε στο 0 τον αριθμό που θα σχηματιστεί
start2:
	read						;ανάγνωση χαρακτήρα
	cmp al,'Q'
	je quit1
	cmp al,'q'
	je quit1					;αν δοθεί πλήκτρο εξόδου τερματισμός				
	cmp al,'0'
	jl start2
	cmp al,'9'				
	jg start2					;έλεγχος για ψηφίο (0-9)
	print al					;εκτύπωση χαρακτήρα
	sub al,'0'					;μετατροπή σε δυαδικό αριθμό
	char_dec					;σχηματισμός του δεύτερου αριθμού
	inc cl						;αύξηση μετρητή ψηφίων
start3:
	read                        ;ανάγνωση χαρακτήρα
	cmp al,'Q'
	je quit1
	cmp al,'q'
	je quit1					;αν δοθεί πλήκτρο εξόδου τερματισμός
	cmp al,3dh	
	je return1					;αν δοθεί = επιστροφή
	cmp al,'0'
	jl start3
	cmp al,'9'
	jg start3
	print al					;αν δοθεί ψηφίο (0-9) εκτύπωση
	sub al,'0'					;μετατροπή χαρακτήρα σε δυαδικό αριθμό
	char_dec					;σχηματισμός του δεύτερου αριθμού
	inc cl						;αύξηση μετρητή ψηφίων
	cmp cl,4					;αν έχουν συμπληρωθεί 4 ψηφία
	je ent						;περιμένουμε =
	jmp start3					;αλλιώς επανάληψη
ent:
	read						
	cmp al,'Q'
	je quit1
	cmp al,'q'
	je quit1					;αν δοθεί πλήκτρο εξόδου τερματισμός
	cmp al,3dh
	je return1					;αν δοθεί = επιστροφή
	jmp ent						;αλλιώς συνεχίζουμε να περιμένουμε για =
return1:
	ret
quit1:
	exit
read_number2 endp

result proc far					;ρουτίνα υπολογισμού και εκτύπωσης αποτελέσματος
	push dx						;Ο DX (αριθμός 2) επηρεάζεται από την macro PRINT 
								;γι αυτό τον σώζουμε στην στοίβα
	print '='					;τυπώνουμε '=' 
	pop dx						;επαναφορά του DX από τη στοίβα
	cmp ch,'+'					;έλεγχος συμβόλου πράξης
	je addn						;αν δόθηκε (+) άλμα στο addn για πρόσθεση
								;αλλιώς αφαίρεση (-)
	mov ch,0					;σημαία αρνητικού προσήμου = 0 (false)
	cmp bx,dx					;συγκρίνουμε BX,DX (αριθμός 1, αριθμός 2)
	jl minus					;αν ΒΧ < DX (δηλ. BX - DX < 0) άλμα στο minus
	sub bx,dx					;αλλιώς κάνουμε κανονικά την αφαίρεση BX - DX
								;(αποτέλεσμα στον BX)
	jmp prnt					;άλμα στο prnt για εκτύπωση του αποτελέσματος
addn:
	add bx,dx					;πρόσθεση BX + DX και το αποτέλεσμα στον BX
	jmp prnt					;άλμα στο prnt για εκτύπωση του αποτελέσματος
minus:
	push dx	
	print '-'					;εκτύπωση αρνητικού προσήμου
	pop dx						;σώζουμε στη στοίβα και στη συνέχεια επαναφέρουμε τον DX
	mov ch,1					;σημαία αρνητικού αποτελέσματος = 1 (true)
	sub dx,bx					;γίνεται η αφαίρεση DX - BX (DX - BX > 0)
	mov bx,dx					;αποθήκευση αποτελέσματος στον BX
prnt:
	mov al,0					;σημαία πρώτου <> 0 ψηφίου = 0 (false)
	push bx						;αποθήκευση αποτελέσματος στη στοίβα
	and bx,0f000h				;απομόνωση 4 MSB (1ου hex ψηφίου)
	jz continue1				;αν το ψηφίο είναι 0 συνέχισε
	mov al,1					;αλλιώς πρώτα η σημαία πρώτου <> 0 ψηφίου γίνεται 1 (true)
								;(έχουμε βρει το πρώτο μη μηδενικό ψηφίο για εκτύπωση)
continue1:
	mov cl,12              
	shr bx,cl                   ;τοποθέτηση hex ψηφίου στη σωστή θέση
	call print_hex				;και εκτύπωση
	pop bx						;επαναφορά αποτελέσματος
	push bx						;επαναλαμβάνουμε τη διαδικασία για τα επόμενα hex ψηφία
								;του αποτελέσματος (συνολικά έχουμε 4 hex ψηφία)
	and bx,0f00h
	jz continue2
	mov al,1
continue2:
	mov cl,8
	shr bx,cl
	call print_hex
	pop bx
	push bx
	and bx,0f0h
	jz continue3
	mov al,1
continue3:
	mov cl,4
	shr bx,cl
	call print_hex
	pop bx
	push bx
	and bx,0fh
	mov al,1
	call print_hex
	pop bx
	print '='					 ;εκτύπωση '='
	cmp ch,1					 ;έλεγχος σημαίας αρνητικού αποτελέσματος
	jne proceed					 ;αν είναι false συνεχίζουμε
	print '-'					 ;αλλιώς πρώτα τυπώνουμε μείον (-)
proceed:						 ;εδώ παίρνουμε το αποτέλεσμα (σε δυαδική μορφή)
								 ;και λαμβάνουμε ένα προς ένα τα δεκαδικά του ψηφία
	mov cx,0   	;μηδενισμός μετρητή ψηφίων
	mov ax,bx
addr2:
	mov dx,0
	mov bx,10
	div bx		;διαίρεσε τον αριθμό με το 10
	push dx		;Αποθήκευσε το υπόλοιπο στη στοίβα
	inc cx		;Αύξησε το μετρητή ψηφίων
	cmp ax,0	;όταν το πηλίκο είναι 0 δεν υπάρχει άλλο φηφίο
	jnz addr2
addr3:
	pop dx		;διάβασε από τη στοίβα ένα ψηφίο
	add dx,30h	;μετατροπή σε χαρακτήρα και εκτύπωση
	print dl
	loop addr3
	ret
result endp
code_seg ends
end