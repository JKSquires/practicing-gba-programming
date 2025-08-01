b start

@include header.asm

start:
mov r0,0x4000000
ldr r1,=0x403
strh r1,[r0]

mov r1,0x3000000
ldr r2,=0x1A7F
strh r2,[r1]

str r1,[r0,0xD4] ; source

mov r1,0x6000000
str r1,[r0,0xD8] ; destination

ldr r1,=(%10000001000 << 21 | 240 * 160) ; immediately enable 16-bit fixed-source DMA transfer to incrementing destination addresses (240px height * 160px width) times
str r1,[r0,0xDC] ; control

loop:
b loop 
