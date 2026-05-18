b start ; first 4 bytes MUST be a branch to the start of the program

@include header.asm ; needs the gba header

palette:
@DCW %0000000000000000 ; remember, the first color in the palette is "transparent"
@DCW %0000000000011111
@DCW %0111111111100000
@DCW %0000001111111111
@DCW %0111111111111111
@DCW %0100001000010000

car_sprite_row0: ; 32x16 sprite (remember: top left corner is (0,0) the positive directions are right and down)
; character in sprite at (0,0)
@DCD 0x00000000
@DCD 0x11111000
@DCD 0x21212110
@DCD 0x21212210
@DCD 0x41221221
@DCD 0x21222121
@DCD 0x21222121
@DCD 0x11111111
; character in sprite at (1,0)
@DCD 0x00000000
@DCD 0x11111111
@DCD 0x22221222
@DCD 0x22421224
@DCD 0x22241222
@DCD 0x22221222
@DCD 0x22221222
@DCD 0x22221221
; character in sprite at (2,0)
@DCD 0x00000000
@DCD 0x00000001
@DCD 0x00000111
@DCD 0x00011212
@DCD 0x00124212
@DCD 0x01242212
@DCD 0x12222212
@DCD 0x22222212
; character in sprite at (3,0)
@DCD 0x00000000
@DCD 0x00000000
@DCD 0x00000000
@DCD 0x00000000
@DCD 0x00000000
@DCD 0x00000000
@DCD 0x00000000
@DCD 0x00000001
car_sprite_row1:
; character in sprite at (0,1)
@DCD 0x11111113
@DCD 0x51111113
@DCD 0x11111113
@DCD 0x15551111
@DCD 0x55555111
@DCD 0x55555110
@DCD 0x55555000
@DCD 0x05550000
; character in sprite at (1,1)
@DCD 0x11111111
@DCD 0x11551115
@DCD 0x11111111
@DCD 0x11111111
@DCD 0x11111111
@DCD 0x11111111
@DCD 0x00000000
@DCD 0x00000000
; character in sprite at (2,1)
@DCD 0x11111111
@DCD 0x11111111
@DCD 0x11111111
@DCD 0x11111111
@DCD 0x51111111
@DCD 0x51111111
@DCD 0x50000000
@DCD 0x00000000
; character in sprite at (3,1)
@DCD 0x00001111
@DCD 0x00111111
@DCD 0x04111111
@DCD 0x54111555
@DCD 0x51115555
@DCD 0x55115555
@DCD 0x00005555
@DCD 0x00000555

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
orr r1,r1,3 ; number of 32-bit sections to transfer
str r1,[r0,0xDC] ; DMA 3 control register (0x40000DC)

; transfer sprite data to VRAM OBJ character data
addr r1,car_sprite_row0 ; source start address (row 0)
str r1,[r0,0xD4] ; DMA 3 source address register (0x40000D4)

ldr r2,=0x6010020 ; destination start address (0x6010020. VRAM OBJ character data: 0x6010000. I want the sprite to start at character 1, meaning that the first row starts at 0x20 offset from 0x6010000)
str r2,[r0,0xD8] ; DMA 3 destination address register (0x40000D8)

mov r3,(%10000100000 << 21) ; set to use 32-bit transfers and DMA enabled flag
orr r3,r3,32 ; number of 32-bit sections to transfer
str r3,[r0,0xDC] ; DMA 3 control register (0x40000DC)

addr r1,car_sprite_row1 ; source start address (row 1)
str r1,[r0,0xD4] ; DMA 3 source address register (0x40000D4)

add r2,r2,0x400 ; destination start address (0x6010420. VRAM OBJ character data: 0x6010000. I want the sprite to start at character 1, meaning that the second row starts at 0x420 offset from 0x6010000)
str r2,[r0,0xD8] ; DMA 3 destination address register (0x40000D8)

str r3,[r0,0xDC] ; DMA 3 control register (0x40000DC) (set to use 32-bit transfers and DMA enabled flag. 32 32-bit sections to transfer)

; set up the object
mov r1,0x7000000 ; OAM

mov r2,%0100000000000000 ; OBJ 0 attribute 0: y144, 16-color sprite, and horizontal rectangle shape
orr r2,r2,%0000000010010000 ; "
strh r2,[r1] ; OBJ 0 attribute 0 (0x7000000)

mov r2,%1000000000000000 ; OBJ 0 attribute 1: x0, set dimension for 0b10 (in this case, 32x16)
strh r2,[r1,2] ; OBJ 0 attribute 1 (0x7000002)

mov r2,%0000000000000001 ; OBJ 0 attribute 2: start sprite at character 1, use color palette 0
strh r2,[r1,4] ; OBJ 0 attribute 2 (0x7000004)

mainLoop:
; wait for next v-blank
waitForVBlankEnd:
ldrh r2,[r0,0x4] ; LCD status register (a.k.a. DISPSTAT)
tst r2,1 ; test if inside v-blank interval
bne waitForVBlankEnd ; if inside, try again
waitForVBlankStart:
ldrh r2,[r0,0x4] ; DISPSTAT
tst r2,1 ; test if inside v-blank interval
beq waitForVBlankStart ; if not inside, try again

; car move logic
ldrh r2,[r1,2] ; get OBJ 0 attribute 1 (conveniently has both the x-coordinate and the horizontal flip flag)

and r3,r2,%11111111; get the x-coordinate of the car
cmp r3,%11010000 ; check if the car is all the way to the right
orreq r2,r2,%0001000000000000 ; set the horizontal flip flag for the sprite if it is

tst r2,%11111111 ; check if the car is all the way to the left
mvneq r3,%0001000000000000 ; create the bitmask for clearing the vertical flip flag if it is
andeq r2,r2,r3 ; clear the horizontal flip flag for the sprite if it is

tst r2,%0001000000000000 ; check the direction of the car (if the sprite is flipped or not)
addeq r2,r2,1 ; move the car to the right if the sprite is not flipped
subne r2,r2,1 ; move the car to the left if the sprite is flipped

strh r2,[r1,2] ; store the modified OBJ 0 attribute 1

b mainLoop ; loop
