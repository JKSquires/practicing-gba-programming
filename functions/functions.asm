b start

@include header.asm

drawPixel: ; r0: x-coord; r1: y-coord; r2: color. Uses registers r3-r4
mov r3,0xF0
mul r4,r1,r3
add r4,r4,r0
mov r4,r4,lsl 1

orr r3,r4,0x6000000
strh r2,[r3]

mov r15,r14 ; set the program counter (r15) to the value in the link register (r14)

start:
mov r0,0x4000000
ldr r1,=0x403
strh r1,[r0]

mov r0,10
mov r1,20
mov r2,0xFF
bl drawPixel

mov r0,20
mov r1,10
mov r2,0xFF0
bl drawPixel

loop:
b loop
