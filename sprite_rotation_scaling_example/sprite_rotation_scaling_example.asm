b start ; first 4 bytes MUST be a branch to the start of the program

@include header.asm ; needs the gba header

palette:
@DCW %0000000000000000 ; remember, the first color in the palette is "transparent"
@DCW %0000001111100000
@DCW %0000001100000000
@DCW %0000000000000000

sprite:
@DCD 0x00000000
@DCD 0x00000000
@DCD 0x01110000
@DCD 0x13112110
@DCD 0x11111111
@DCD 0x02111221
@DCD 0x01002111
@DCD 0x11011110

start:
mov r0,0x4000000 ; I/O and registers

; set up display
mov r1,%1010000000000 ; use background mode 0, use 2-dimensional character mapping, turn on background 2, and enable OBJ window
strh r1,[r0] ; display control regiser (a.k.a. DISPCNT)

; transfer palette data to OBJ palette RAM
addr r1,palette ; source start address
str r1,[r0,0xD4] ; DMA 3 source address register (0x40000D4)

mov r1,0x5000000
orr r1,r1,0x200 ; destination start address (OBJ palette RAM: 0x5000200. Using palette 0)
str r1,[r0,0xD8] ; DMA 3 destination address register (0x40000D8)

mov r1,(%10000100000 << 21) ; set to use 32-bit transfers and DMA enabled flag
orr r1,r1,2 ; number of 32-bit sections to transfer
str r1,[r0,0xDC] ; DMA 3 control register (0x40000DC)

; transfer sprite data to VRAM OBJ character data
addr r1,sprite ; source start address
str r1,[r0,0xD4] ; DMA 3 source address register (0x40000D4)

ldr r1,=0x6010020 ; destination start address (0x6010020. VRAM OBJ character data: 0x6010000. I want the sprite to start at character 1, so I'm starting at 0x20 offset from 0x6010000)
str r1,[r0,0xD8] ; DMA 3 destination address register (0x40000D8)

mov r1,(%10000100000 << 21) ; set to use 32-bit transfers and DMA enabled flag
orr r1,r1,8 ; number of 32-bit sections to transfer
str r1,[r0,0xDC] ; DMA 3 control register (0x40000DC)

; set up the object
mov r0,0x7000000 ; OAM

mov r1,%0000001101000000 ; OBJ 0 attribute 0: y64, rotation and scaling enabled, double-size enabled, 16-color sprite, and square shape
strh r1,[r0] ; OBJ 0 attribute 0 (0x7000000)

mov r1,%0000000010000000 ; OBJ 0 attribute 1: x128, use matrix 0 for rotation and scaling, set dimension for 0b00 (in this case, 8x8)
strh r1,[r0,0x2] ; OBJ 0 attribute 1 (0x7000002)

mov r1,%0000000000000001 ; OBJ 0 attribute 2: start sprite at character 1, use color palette 0
strh r1,[r0,0x4] ; OBJ 0 attribute 2 (0x7000004)

; set up the transformation matrix
mov r1,%0000000010010011 ; 0.5cos(-pi/6) = ~111/256
strh r1,[r0,0x6] ; M0A

mvn r1,%0000000001010101 ; -0.5sin(-pi/6) = -64/256
strh r1,[r0,0x0E] ; M0B

mov r1,%0000000001010101 ; 0.5sin(-pi/6) = 64/256
strh r1,[r0,0x16] ; M0C

mov r1,%0000000010010011 ; 0.5cos(-pi/6) = ~111/256
strh r1,[r0,0x1E] ; M0D

; infinite loop
loop:
b loop
