b start

@include header.asm

start:
mov r0,0x4000000
ldr r1,=0x403
strh r1,[r0]

mov r1,0x3000000
ldr r2,=0x12A20 ; y-bounds
str r2,[r1]

mov r1,0xF0
mov r2,0x9600
mov r3,%11 ; bits: xy 0:- 1:+

ldr r4,=0x7FFF

loop:
waitVBlankEnd:
ldrh r5,[r0,0x4]
tst r5,1
beq waitVBlankEnd
waitVBlankStart:
ldrh r5,[r0,0x4]
tst r5,1
bne waitVBlankStart

add r5,r1,r2
add r5,r5,0x6000000

mov r6,0
strh r6,[r5]

cmp r1,0
orrle r3,r3,%10

mov r5,0x1E0
sub r5,r5,2

cmp r1,r5
andge r3,r3,%01

tst r3,%10 ; x
subeq r1,r1,2
addne r1,r1,2

cmp r2,0
orrle r3,r3,%01

mov r6,0x3000000
ldr r5,[r6]

cmp r2,r5
andge r3,r3,%10

tst r3,%01 ; y
subeq r2,r2,0x1E0
addne r2,r2,0x1E0

add r5,r1,r2
add r5,r5,0x6000000
strh r4,[r5]

b loop
