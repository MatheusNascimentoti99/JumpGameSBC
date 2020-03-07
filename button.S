 
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
        i: .ascii "i"
        e: .ascii "e"
        l: .ascii "l"
        p: .ascii "p"
        u: .ascii "u"
        c: .ascii "c"
        n: .ascii "n"
        P: .ascii "P"
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
        .equ    PIN_BTN,17        		@ button pin
        .equ	MAX, 10				@ maximum value of the counter

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
            ldr r9,=PIN_BTN
            bl read
            mov r8, #0
read:
        push	{lr}
        ldr     r0, deviceAddr  		@ address of /dev/gpiomem
        ldr     r1, openMode    		@ flags for accessing device
        bl      open
        cmp     r0, #-1          		@ check for error
        bne     gpioMemOK       		@ no error, continue
        bl endGPIO
        b main
gpioMemOK:      
        mov     r4, r0          		@ use r4 for file descriptor
        ldr	r5, gpio			@ address of the GPIO
        push	{r4, r5}
        mov     r0, #NO_PREF     		@ let kernel pick memory
        mov     r1, #PAGE_SIZE   		@ get 1 page of memory
        mov     r2, #PROT_RDWR   		@ read/write this memory
        mov     r3, #MAP_SHARED  		@ share with other processes
        bl      mmap
        pop	{r4, r5}
        cmp     r0, #0          		@ check for error
        bgt     mmapOK          		@ no error, continue
        b main
        
mmapOK:        
        mov     r5, r0          		@ use r5 for programming memory address
        mov     r0, r5          		@ programming memory
        mov     r1, r9       		@ button pin
        mov     r2, #INPUT     			@ it's an input
        bl      gpioPinFSelect  		@ select function        
readPin:
        ldr	r0, =1				@ MODIFY THIS VALUE TO SEE THE EFFECT THE BOUNCE
        bl	usleep
        mov 	r0, r5				@ GPIO programming memory
        mov 	r1, r9			@ pin to read
        bl 	gpioPinRead	
        mov r9, r0
        pop {lr}
        bx lr

        
endGPIO: 
        mov     r0, r4          		@ /dev/gpiomem file descriptor
        bl      close           		@ close the file
        mov r0, #0
        b main
 
        .align  2

deviceAddr:
        .word   device        
openMode:
        .word   O_FLAGS
gpio:
        .word   PERIPH+GPIO_OFFSET
