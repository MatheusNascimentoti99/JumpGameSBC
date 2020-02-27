.data
        .equ    PERIPH,0x3f000000   	// RPi 2 & 3 peripherals
        .equ    GPIO_OFFSET,0x200000  	// start of GPIO device
        .equ    O_RDWR,00000002   		// open for read/write
    
.text
.global main
main:
    mov r0, #16
    bl test
    bl print_val @ do something with the pin value (print it?). Value: 1 if set high, 0 if set low.

test:
    mov r3, #0 
    ldr r0,=0x3f200000 
    ldr r2, [r0, #0]
    lsr r2, r2, r0 @ assuming r0 is set to the pin number to read
    and r0, r2, #1 @ this will clear all values except the least significant bit (our pin value).
    bx lr

print_val:
    b print_val
