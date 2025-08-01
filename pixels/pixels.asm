b start

@include header.asm

start:

mov r0,0x04000000
ldr r1,=0x0403
strh r1,[r0]

ldr r1,=0x7FE0
ldr r2,=0x01DE ; 239px * 2

mov r0,0x06000000
strh r1,[r0]

mov r1,r1,lsr 5 ; note: lsr and lsl seems to be unsupported. The current line still gets assembled into the correct 0xE1A012A1 for lsr r1,r1,5
add r0,r0,r2
strh r1,[r0]

mov r1,r1,lsr 5
ldr r0,=0x06012A20
strh r1,[r0]

mov r1,r1,lsl 5
add r0,r0,r2
strh r1,[r0]

loop:
b loop
