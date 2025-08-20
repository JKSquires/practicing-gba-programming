b start

@include header.asm

palette:
@DCW %0000000000000000
@DCW %0111110000000000
@DCW %0000001111100000
@DCW %0111111111100000
@DCW %0000000000011111
@DCW %0111110000011111
@DCW %0000001111111111
@DCW %0111111111111111
obj: ; pixels will be mirrored from what's below (little-endian)
@DCD 0x01234567
@DCD 0x12345676
@DCD 0x23456765
@DCD 0x34567654
@DCD 0x45676543
@DCD 0x56765432
@DCD 0x67654321
@DCD 0x76543210

start:
mov r0,0x4000000
ldr r1,=0x1440
strh r1,[r0]

mov r1,0x7000000
ldr r2,=%00000000000010100000000000010100 ; 8x8 obj at (10,20)
str r2,[r1]+4

mov r2,1 ; character 1 (the other empty sprites are all 0 by default)
strh r2,[r1]

; DMA tranfer palette to 0x5000200
addr r1,palette
str r1,[r0,0xD4]

mov r1,0x5000000
orr r1,r1,0x200
str r1,[r0,0xD8]

ldr r1,=(%10000000000 << 21 | 8) ; 8 16-bit transfers: 1 per palette color
str r1,[r0,0xDC]

; DMA transfer obj to 0x6010000 for bg modes 0-2 (or 0x6014000 for bg modes 3-5)
addr r1,obj
str r1,[r0,0xD4]

mov r1,0x6000000
orr r1,r1,0x10000
orr r1,r1,0x20 ; obj is char 1, so skip char 0 in character data
str r1,[r0,0xD8]

ldr r1,=(%10000100000 << 21 | 8) ; 8 32-bit transfers: 1 per obj pixel row
str r1,[r0,0xDC]

loop:
b loop
