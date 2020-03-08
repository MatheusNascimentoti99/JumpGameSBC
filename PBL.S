@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@R9 Utilizado para parâmetro de caractere
@R11 Contador do delay
@R4 Contador do delay (Parte dinâmica para aumentar a velocidade)
@R7 Syscall
@R0 Retorno Syscall
@R1 Parâmetro Syscall
@R2 PArâmetro Syscal
@R12 Valor de score
@R8  Valor da centena do score
@R5 simboliza o personagem em cima
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
.data
    
@ button32.s
@ Decrements a counter as a button connected to pin 17 is pressed.
@ Prints the value of the counter on the screen till it reaches 0.

@ Define my Raspberry Pi
        .cpu    cortex-a53
        .fpu    neon-fp-armv8
        .syntax unified         		@ modern syntax

@ Constants for assembler
        .equ    PERIPH,0x3f000000   		@ RPi 2 & 3 peripherals
        .equ    GPIO_OFFSET,0x200000  		@ start of GPIO device
@ The following are defined in /usr/include/asm-generic/fcntl.h:
@ Note that the values are specified in octal.
        .equ    O_RDWR,00000002   		@ open for read/write
        .equ    O_DSYNC,00010000
        .equ    __O_SYNC,04000000
        .equ    O_SYNC,__O_SYNC|O_DSYNC

@ The following are defined in /usr/include/asm-generic/mman-common.h:
        .equ    PROT_READ,0x1   		@ page can be read
        .equ    PROT_WRITE,0x2  		@ page can be written
        .equ    MAP_SHARED,0x01 		@ share changes

@ The following are defined by me:
        .equ    O_FLAGS,O_RDWR|O_SYNC 	@ open file flags
        .equ    PROT_RDWR,PROT_READ|PROT_WRITE
        .equ    NO_PREF,0
        .equ    PAGE_SIZE,4096  		@ Raspbian memory page
        .equ    INPUT,0         		@ use pin for input
        .equ    OUTPUT,1        		@ use pin for ouput
        .equ    PIN_BTN_Jump,27        		@ button pin Jump
        .equ    PIN_BTN_Pause,17        		@ button pin Pause
        
        
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
    baseNumbers:                    @Vetor de caracteres numericos 
        .word zero
        .word um
        .word dois
        .word tres
        .word quatro
        .word cinco
        .word seis
        .word sete 
        .word oito 
        .word nove 
    filepath: .asciz "/dev/lcd_1602"    @Caminho do LCD
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
    .equ count, 10000000            @contador do delay
    .equ countDecres, 1057172
    @ Constant program data
        .section .rodata
        .align  2
    device:
        .asciz  "/dev/gpiomem"
.text
    .align  2
    .global main
    .type   main, %function
main:
    BL clear
    Bl home_title
    b home

home:
    LDR R5,=esp
    MOV R12,#0
    MOV R8,#0
    LDR R0,=count 
    BL dbounce
    LDR R9,=PIN_BTN_Jump
    BL readButton
    BL endGPIO
    CMP R9, #1
    BNE home
    BL dbounce
    B game
    
dbounce:
    PUSH {LR}
    LDR R0,=count
    B wait
wait:
    SUB R0, R0, #1
    CMP R0, #0
    BGT wait
    POP {lr}
    BX lr
    
clearTest:
    bl clear
    b end
    
game:
    LDR R11,=count
    LDR R9,=PIN_BTN_Pause
	BL readButton
	BL endGPIO
	CMP R0,#1
	BEQ pauseGame
    B movingPerson
    
gameplay:
    ADD R12, R12, #1
	LDR R10, =cenario
	MOV R3,#16
	B moveCen
    
moveCen:
	CMP R3, #0
	BEQ movingOn
	LDR R1, [R10, #4]	@Botar #4 aqui
	CMP R1, #0
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
    LDR R1, [R10, #0]
    LDR R7, [R10, #4]
    STR R7, [R10, #0]
    STR R1, [R10, #4]
    SUB R3, R3, #1
    BX LR
		
delay:	
	SUB R11, R11, #1
	CMP R11, #0
	BNE delay
	B game
	
	
end:
    B end
  
@Função utilizada para escrever no LCD
@Param R9 é utilizado para definir qual caractere deseja-se imprimir
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
    LDR R2,=x                       @x=1 que é a primeira linha
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
    LDR R2,=y                   @x=2 que é a segunda linha
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

score:
    SUB sp, sp, #8
    STR LR, [sp]
    BL hund             @Usada para imprimir qual o valor da centena
    BL scoreUniDEZ      @Usada para imprimir qual o valor da dezena e unidade
	LDR LR,[sp]
	ADD sp, sp, #8
	BX LR
  
@Função feita para definir qual unidade será impressa
scoreUniDEZ:
	CMP R12, #9                
	BLE uni        @Se count <= 9, então imprime só unidade
	CMP R12, #19
	BLE dec1       @Se count <= 19, então imprime na dezena o valor "1"
	CMP R12, #29
	BLE dec2
	CMP R12, #39
	BLE dec3
	CMP R12, #49
	BLE dec4
	CMP R12, #59
	BLE dec5
	CMP R12, #69
	BLE dec6
	CMP R12, #79
	BLE dec7
	CMP R12, #89
	BLE dec8
	CMP R12, #99
	BLE dec9

	BX LR
	

uni:
	SUB sp, sp, #8
    STR LR, [sp]
	LDR R9,=baseNumbers
	LDR R9, [r9,#0]             @Imprime o valor "0"
	BL write
	
	LDR R9,=baseNumbers
	LSL R1, R12, #2
	ADD R9, R9, R1             @baseNumbers + count*4 = Posição do número que deseja imprimir
	LDR R9, [r9,#0]
	BL write
	LDR LR,[sp]
	ADD sp, sp, #8
	BX LR
	
dec1:
    SUB sp, sp, #8          
    STR LR, [sp]
	LDR R9,=baseNumbers
	LDR R9, [r9,#4]            @Imprime a valor da posição 1 correspondente a "um" do array
	BL write
	
	LDR R9,=baseNumbers
	SUB R1, R12, #10
	LSL R1, R1, #2             @count * 4
	ADD R9, R9, R1             @baseNumbers + count*4 = Posição do número que deseja imprimir
	LDR R9, [r9,#0]
	BL write
	LDR LR,[sp]
	ADD sp, sp, #8
	BX LR

dec2:
    SUB sp, sp, #8
    STR LR, [sp]
	LDR R9,=baseNumbers
	LDR R9, [r9,#8]
	BL write
	
	LDR R9,=baseNumbers
	SUB R1, R12, #20
	LSL R1, R1, #2
	ADD R9, R9, R1
	LDR R9, [r9,#0]
	BL write
	LDR LR,[sp]
	ADD sp, sp, #8
	BX LR

dec3:
    SUB sp, sp, #8
    STR LR, [sp]
	LDR R9,=baseNumbers
	LDR R9, [r9,#12]
	BL write
	
	LDR R9,=baseNumbers
	SUB R1, R12, #30
	LSL R1, R1, #2
	ADD R9, R9, R1
	LDR R9, [r9,#0]
	BL write
	LDR LR,[sp]
	ADD sp, sp, #8
	BX LR

dec4:
    SUB sp, sp, #8
    STR LR, [sp]
	LDR R9,=baseNumbers
	LDR R9, [r9,#16]
	BL write
	
	LDR R9,=baseNumbers
	SUB R1, R12, #40
	LSL R1, R1, #2
	ADD R9, R9, R1
	LDR R9, [r9,#0]
	BL write
	LDR LR,[sp]
	ADD sp, sp, #8
	BX LR

dec5:
    SUB sp, sp, #8
    STR LR, [sp]
	LDR R9,=baseNumbers
	LDR R9, [r9,#20]
	BL write
	
	LDR R9,=baseNumbers
	SUB R1, R12, #50
	LSL R1, R1, #2
	ADD R9, R9, R1
	LDR R9, [r9,#0]
	BL write
	LDR LR,[sp]
	ADD sp, sp, #8
	BX LR

dec6:
    SUB sp, sp, #8
    STR LR, [sp]
	LDR R9,=baseNumbers
	LDR R9, [r9,#24]
	BL write
	
	LDR R9,=baseNumbers
	SUB R1, R12, #60
	LSL R1, R1, #2
	ADD R9, R9, R1
	LDR R9, [r9,#0]
	BL write
	LDR LR,[sp]
	ADD sp, sp, #8
	BX LR

dec7:
    SUB sp, sp, #8
    STR LR, [sp]
	LDR R9,=baseNumbers
	LDR R9, [r9,#28]
	BL write
	
	LDR R9,=baseNumbers
	SUB R1, R12, #70
	LSL R1, R1, #2
	ADD R9, R9, R1
	LDR R9, [r9,#0]
	BL write
	LDR LR,[sp]
	ADD sp, sp, #8
	BX LR

dec8:
    SUB sp, sp, #8
    STR LR, [sp]
	LDR R9,=baseNumbers
	LDR R9, [r9,#32]
	BL write
	
	LDR R9,=baseNumbers
	SUB R1, R12, #80
	LSL R1, R1, #2
	ADD R9, R9, R1
	LDR R9, [r9,#0]
	BL write
	LDR LR,[sp]
	ADD sp, sp, #8
	BX LR

dec9:
    SUB sp, sp, #8
    STR LR, [sp]
	LDR R9,=baseNumbers
	LDR R9, [r9,#36]
	BL write
	
	LDR R9,=baseNumbers
	SUB R1, R12, #90
	LSL R1, R1, #2
	ADD R9, R9, R1
	LDR R9, [r9,#0]
	BL write
	LDR LR,[sp]
	ADD sp, sp, #8
	BX LR
    
@Função utilizada verificar a centena da pontuação
@Se o contador da pontuação for maior que 99, então será incrementado +1 na contador da centena. 
@Se não, então chamará a função printHund para imprimir o valor atual da centena

hund:
    SUB sp, sp, #8
    STR LR, [sp]
    CMP r12, #99
    BLE printHund
    ADD R8, R8, #1          @cout da pontuação, passa um para a centena
    MOV R12, #0             @zera o contador Dez_unidade 
    B score
	
@Função utilizada para imprimir a centena da pontuação
@Move o cursor para a coluna 14 e imprime o valor da centena
@R8 contém o valor da centena
@
printHund:

    BL setColl14
    LDR R9,=baseNumbers
    LSL R1, R8, #2
	ADD R9, R9, R1
	LDR R9, [r9,#0]
	BL write
    LDR LR,[sp]
	ADD sp, sp, #8
	BX LR

setColl14:
    SUB sp, sp, #8
    STR LR, [sp]  
    BL set_position_UP
	MOV R9,R5	
	BL write
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
	LDR LR,[sp]
	ADD sp, sp, #8
	BX LR

@ Máquina de estados para verificar a colisão e movimentação do personagem
movingPerson:
    BL score
    LDR R9,=PIN_BTN_Jump
	BL readButton
	LDR R10,=cenario
	CMP R0,#1
	BL endGPIO
	BEQ buttonUp
	B buttonDown					
buttonDown:
	LDR R1,=person		@R5 é o personagem
	CMP R1, R5		@Verifica se o jogador está em cima do bloco
	BEQ inUp				
	LDR R1, [R10, #0]
	CMP R1, #1		@Verifica se o próximo elemento do cenário é um bloco
	BEQ collider		
	B moveDown		@Se nenhuma das situações acontecerem, então ele se mantém na parte de baixo

buttonUp:	
	LDR R1,=person		@R5 é o personagem
	CMP R1, R5		@Verifica se o jogador está em cima do bloco
	BEQ inUp
	B moveUp		@Caso ele não esteja na parte de cima, então será realizada a ação de pular

moveUp:
	BL set_position_UP
	LDR R5,=person
	LDR R9,=person		@Move o personagem de cima
	BL write
	BL set_position_DOWN	@Deixa o cursor na linha de baixo novamente
	B gameplay

moveDown:
	BL set_position_UP
	LDR R5,=esp
	LDR R9,=esp		@Apaga o personagem de cima
	BL write
	
	BL set_position_DOWN
	LDR R9,=person
	BL write		@Move o personagem para baixo
	B gameplay

inUp:
	LDR R1, [R10, #4]
	CMP R1, #0		@e o próximo elemento do cenario for um espaço, então o personagem vai descer do bloco
	BEQ moveDown
	B moveUp		@Caso contrário, então ele continua na parte de cima

collider:
	B main		@Reinicia o jogo
	
	
pauseGame:
    BL dbounce
    LDR R9,=PIN_BTN_Jump
    BL readButton
    BL endGPIO
	LDR R1,=i
    MOV R7, #4
    MOV R0, #1
    MOV R2, #1
    SWI 0
    CMP R9,#1
    BEQ returnGame
	b pauseGame
    
returnGame:
    b movingPerson
    
@Código adaptado para leitura do botão
readButton:
        push	{r12, lr}
        ldr     r0, deviceAddr  		@ address of /dev/gpiomem
        ldr     r1, openMode    		@ flags for accessing device
        MOV R7, #5     
        SWI 0
        cmp     r0, #-1          		@ check for error
        bne     gpioMemOK       		@ no error, continue
        bl endGPIO
        pop {r12, lr}
        b end
gpioMemOK:      
        mov     r4, r0          		@ use r4 for file descriptor
        ldr	r10, gpio			@ address of the GPIO
        push	{r4, r10}
        mov     r0, #NO_PREF     		@ let kernel pick memory
        mov     r1, #PAGE_SIZE   		@ get 1 page of memory
        mov     r2, #PROT_RDWR   		@ read/write this memory
        mov     r3, #MAP_SHARED  		@ share with other processes
        bl      mmap
        pop	{r4, r10}
        cmp     r0, #0          		@ check for error
        bgt     mmapOK          		@ no error, continue
        pop {r12, lr}
        b end
        
mmapOK:        
        mov     r10, r0          		@ use r5 for programming memory address
        mov     r0, r10          		@ programming memory
        mov     r1, r9       		@ button pin
        mov     r2, #INPUT     			@ it's an input
        bl      gpioPinFSelect  		@ select function        
readPin:
        mov 	r0, r10				@ GPIO programming memory
        mov 	r1, r9			@ pin to read
        bl 	gpioPinRead	
        mov r9, r0
        pop {r12, lr}
        
        bx lr

        
endGPIO: 
        push    {r0}
        mov     r0, r4          		@ /dev/gpiomem file descriptor
        MOV R7, #6
        SWI 0               @Close
        pop     {r0}
        BX LR
 
        .align  2

deviceAddr:
        .word   device        
openMode:
        .word   O_FLAGS
gpio:
        .word   PERIPH+GPIO_OFFSET
