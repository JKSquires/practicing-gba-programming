@define X1 200 ; 0-239
@define Y1 10 ; 0-159
@define X2 60 ; 0-239
@define Y2 100 ; 0-159

@define MINCOLOR 0x6318
@define MAXCOLOR 0x7FFF

b start

@include header.asm

start:
mov r0,0x4000000
ldr r1,=0x403
strh r1,[r0]

mov r0,0x3000000

ldr r1,=X1
strb r1,[r0,0]
ldr r1,=X2
strb r1,[r0,1]
ldr r1,=Y1
strb r1,[r0,2]
ldr r1,=Y2
strb r1,[r0,3]

ldr r1,=MAXCOLOR
strh r1,[r0,4]

ldr r12,=MINCOLOR
strh r12,[r0,8]

mov r11,0

mainLoop:
mov r8,0x4000000
waitVBlankEnd:
ldrh r1,[r8,0x4]
tst r1,1
bne waitVBlankEnd
waitVBlankStart:
ldrh r1,[r8,0x4]
tst r1,1
beq waitVBlankStart

ldrb r1,[r0,0]
ldrb r2,[r0,1]
ldrb r3,[r0,2]
ldrb r4,[r0,3]

ldr r5,=238 ; x-limit check 238
ldr r6,=158 ; y-limit check 158

ldrb r7,[r8,0x130]

tst r7,%0000000001
moveq r11,0
tst r7,%0000000010
moveq r11,1

cmp r11,0
bne lControl
cmp r2,r5
tstle r7,%0000010000
addeq r2,r2,1

cmp r2,1
tstge r7,%0000100000
subeq r2,r2,1

cmp r4,0x1
tstge r7,%0001000000
subeq r4,r4,1

cmp r4,r6
tstle r7,%0010000000
addeq r4,r4,1

b skipLControl
lControl:
cmp r1,r5
tstle r7,%0000010000
addeq r1,r1,1

cmp r1,1
tstge r7,%0000100000
subeq r1,r1,1

cmp r3,0x1
tstge r7,%0001000000
subeq r3,r3,1

cmp r3,r6
tstle r7,%0010000000
addeq r3,r3,1
skipLControl:

strb r1,[r0,0]
strb r2,[r0,1]
strb r3,[r0,2]
strb r4,[r0,3]

mov r7,0

sub r5,r2,r1
cmp r5,r7
sublt r5,r7,r5

sub r6,r4,r3
cmp r6,r7
sublt r6,r7,r6

mov r10,0

cmp r5,r6
bge xy
mov r10,1

mov r5,r1
mov r1,r3
mov r3,r5

mov r5,r2
mov r2,r4
mov r4,r5
xy:

cmp r1,r2
bls skipSwap
mov r5,r1
mov r1,r2
mov r2,r5

mov r5,r3
mov r3,r4
mov r4,r5
skipSwap:

; see Bresenham's line algorithm
sub r5,r2,r1
sub r6,r4,r3
add r6,r6,r6

mov r7,0
mov r4,1
cmp r6,r7
sublt r4,r4,2
sublt r6,r7,r6

mov r7,r6
sub r7,r7,r5

add r5,r5,r5

lineLoop:
mov r8,0xF0 ; 240

cmp r10,0
muleq r9,r3,r8
addeq r9,r9,r1
mulne r9,r1,r8
addne r9,r9,r3
mov r9,r9 lsl 1
orr r9,r9,0x6000000
strh r12,[r9]

cmp r7,0
addgt r3,r3,r4
subgt r7,r7,r5

add r7,r7,r6

cmp r1,r2
add r1,r1,1
bne lineLoop

add r12,r12,0x10
ldrh r8,[r0,4]
cmp r12,r8
ldrgt r12,[r0,8]

b mainLoop:
