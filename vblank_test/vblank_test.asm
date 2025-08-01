b start

white:
@dcw 0x7FFF

start:

mov r0,0x04000000
ldr r1,=0x0403
strh r1,[r0]

orr r0,r0,0x04

mov r1,0x06000000
ldrh r2,[white]

mov r3,0

mov r4,2

loop:
waitVBlankEnd:
ldrh r5,[r0]
tst r5,1
beq waitVBlankEnd
waitVBlankStart:
ldrh r5,[r0]
tst r5,1
bne waitVBlankStart

cmp r3,0
moveq r4,2
ldreq r2,[white] ; I'd prefer to write ldrheq, but goldroad doesn't seem to support that. ldreq works, though.

orr r5,r1,r3
strh r2,[r5]

add r3,r3,r4

cmp r3,0x1E0
subeq r4,r4,4
moveq r2,0
addeq r3,r3,r4
b loop 
