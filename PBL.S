@R9 Utilizado para parâmetro de caractere
@R11 Contador do delay
@R7 Syscall
@R0 Retorno Syscall
@R1 Parâmetro Syscall
@R2 PArâmetro Syscal
@R12 Valor de score
.data

    zero: .ascii "0"
    um: .ascii "1"
    dois: .ascii "2"
    tres: .ascii "3"
    quatro: .ascii "4"
    cinco: .ascii "5"
    seis: .ascii "6"
    sete: .ascii "7"
    oito: .ascii "8"
    nove: .ascii "9"
    filepath: .asciz "/dev/lcd_1602"
    r: .ascii "r"
    a: .ascii "a"
    i: .ascii "i"
    e: .ascii "e"
    l: .ascii "l"
    p: .ascii "p"
    u: .ascii "u"
    c: .ascii "c"
    n: .ascii "n"
    P: .ascii "P"
    
    person: .ascii "¥"
    bloco: .ascii "#"
    excl: .ascii "!"
    esp: .ascii " "
    .align 4
    x: .word 2
    y: .word 1
    
    cenario: .word 0,0,1,1,0,0,0,1,1,1,0,0,1,1,1,1 
    .equ count, 80000000


.text
.global main

main:

    LDR r11,=count
    BL clear
    BL uni
    LDR R1,=i
    MOV R7, #4
    MOV R0, #1
    MOV R2, #12
    SWI 0
    B main
gameplay:
	ADD R13, R13, #1
    	BL set_position_DOWN
	LDR R10, =cenario
	MOV R3,#16
	B moveCen
    
moveCen:
	CMP R3, #0
	BEQ movingOn
	LDR R6, [R10, #0]
	CMP R6, #0
	BEQ adsEsp         	@ Se for 0 escreve espaço
	B adsBlo

adsEsp:
		LDR R9,=esp
		BL write
		ADD R10, R10, #4
		SUB R3, R3, #1
		B moveCen

adsBlo:
		LDR R9,=bloco
		BL write
		ADD R10, R10, #4
		SUB R3, R3, #1
		B moveCen
		
movingOn:
    LDR r10,=cenario			@ Move a base do vetor para o registrador r9
    MOV R3, #16
    B moving					@ O objetivo dele é colocar a primeira posição do vetor para a ultima sem comprometer a ordem do array

moving:		
    CMP R3, #0 
    BEQ delay			@ Se r2 for igual a 0 o processo vai para o delay
    BL swap
    ADD R10, R10, #4 				@ Vai para a proxima posição do array "r9[i] = r9[i+1]"
    B moving

swap:								@ Ele troca a primeira posição para a segunda posição
    LDR R6, [R10, #0]
    LDR R7, [R10, #4]
    STR R7, [R10, #0]
    STR R6, [R10, #4]
    SUB R3, R3, #1
    LDR R1,=i
    MOV R7, #4
    MOV R0, #1
    MOV R2, #1
    SWI 0
    BX LR
		
delay:	
	SUB r11, r11, #1
	CMP r11, #0
	BNE delay
	LDR r11,=count
	B gameplay
	
	
end:
    B end
    
write:
    SUB sp, sp, #8
    STR lr, [sp]
    BL open
    MOV R7, #54                  @IOCTL
    MOV R1, #4                      @put flag
    MOV R2,R9               @Valor deve ser atribuido antes da chamada da função
    SWI 0
    BL close
    LDR LR, [sp]
    ADD sp, sp, #8
    BX LR

set_position_DOWN:
    SUB sp, sp, #8
    STR lr, [sp]
    BL open
    MOV R7, #54                  @IOCTL
    MOV R1, #10
    LDR R2,=x
    SWI 0
    LDR LR, [sp]
    ADD sp, sp, #8
    BX LR
    
set_position_UP:
    SUB sp, sp, #8
    STR lr, [sp]
    BL open
    MOV R7, #54                  @IOCTL
    MOV R1, #10
    LDR R2,=y 
    SWI 0
    LDR LR, [sp]
    ADD sp, sp, #8
    BX LR

    

open:
    MOV R7, #5                  @ função open
    LDR R0, =filepath          @ file pointer 
    MOV R1, #0                  @Permissão de adm
    MOV R2, #00700              @flag
    SWI 0
    BX LR

close: 
    
    MOV R7, #6
    SWI 0               @Close
    BX LR
    


clear:
    SUB sp, sp, #8
    STR LR, [sp]
    BL open
    MOV R7, #54                  @IOCTL
    MOV R1, #1                      @clear flag
    SWI 0
    BL close
    LDR LR, [sp]
    ADD sp, sp, #8
    BX LR
    
home_title:
    SUB sp, sp, #8
    STR LR, [sp]
    LDR R9,=esp
    BL write
    BL write
    BL write
    LDR R9,=P
    BL write
    LDR R9,=u
    BL write
    LDR R9,=l
    BL write
    LDR R9,=e
    BL write
    
    LDR R9,=esp
    BL write
    LDR R9,=p
    BL write
    LDR R9,=a
    BL write
    LDR R9,=r
    BL write
    LDR R9,=a
    BL write
    BL set_position_DOWN
    LDR R9,=esp
    BL write
    BL write
    BL write
    BL write
    LDR R9,=i
    BL write
    LDR R9,=n
    BL write
    LDR R9,=i
    BL write
    LDR R9,=c
    BL write
    LDR R9,=i
    BL write
    LDR R9,=a
    BL write
    LDR R9,=r
    BL write
    LDR R9,=excl
    BL write
    LDR LR, [sp]
    ADD sp, sp, #8
    BX LR
    
scoreDec_Uni:

	CMP R13, #9
	BLE uni

	BX LR
	

uni:
	SUB sp, sp, #8
    	STR LR, [sp]
	BL set_position_UP
	LDR R9,=esp
	BL write
	BL write
	BL write
	BL write
	BL write
	BL write
	BL write
	BL write
	BL write
	BL write
	BL write
	BL write
	BL write
	BL write
	BL write
	LDR R9,=adress_zero
	LDR R9, [R9,#56] 
	BL write
	LDR LR,[sp]
	ADD sp, sp, #8
	LDR R1,[r9]
    	
	MOV R7, #4
    	MOV R0, #1
    	MOV R2, #12
    	SWI 0
	B end

adress_zero:
	.word zero
