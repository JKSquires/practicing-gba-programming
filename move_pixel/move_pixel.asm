b start

@include header.asm

start:

mov r0,0x4000000
ldr r1,=0x403
strh r1,[r0]

mov r1,0x6000000
ldr r2,=0x7FFF

mov r3,0
mov r4,0

ldr r5,=476 ; x-limit check 238 * 2
ldr r6,=75840 ; y-limit check 158 * 240 * 2

loop:
waitVBlankEnd:
ldrh r7,[r0,0x4]
tst r7,1
bne waitVBlankEnd
waitVBlankStart:
ldrh r7,[r0,0x4]
tst r7,1
beq waitVBlankStart

ldrb r7,[r0,0x130]

cmp r3,r5
tstle r7,%0000010000
addeq r3,r3,2

cmp r3,2
tstge r7,%0000100000
subeq r3,r3,2

cmp r4,0x1E0
tstge r7,%0001000000
subeq r4,r4,0x1E0

cmp r4,r6
tstle r7,%0010000000
addeq r4,r4,0x1E0

add r7,r4,r3
strh r2,[r1,r7]
b loop 
