@define X1 200 ; 0-239
@define Y1 10 ; 0-159
@define X2 60 ; 0-239
@define Y2 100 ; 0-159

b start

@include header.asm

start:
mov r0,0x04000000
ldr r1,=0x0403
strh r1,[r0]

ldr r1,=X1
ldr r2,=X2
ldr r3,=Y1
ldr r4,=Y2

sub r5,r2,r1
sub r6,r4,r3

mov r7,0

cmp r5,r7
sublt r8,r7,r5

cmp r6,r7
sublt r9,r7,r6

mov r10,0

cmp r8,r9
movle r5,r8
bgt xy
mov r10,1

mov r0,r1
mov r1,r3
mov r3,r0

mov r0,r2
mov r2,r4
mov r4,r0
xy:

cmp r1,r2
bls skipSwap
mov r0,r1
mov r1,r2
mov r2,r0

mov r0,r3
mov r3,r4
mov r4,r0
skipSwap:

ldr r0,=0x07FFF

; see Bresenham's line algorithm
sub r5,r2,r1
sub r6,r4,r3
add r6,r6,r6

mov r4,1
cmp r6,r7 ; r7 = 0
sublt r4,r4,2
sublt r6,r7,r6

mov r7,r6
sub r7,r7,r5

add r5,r5,r5

mov r8,0xF0 ; 240

lineLoop:
cmp r10,0
mule r9,r3,r8
adde r9,r9,r1
mulne r9,r1,r8
addne r9,r9,r3
mov r9,r9 lsl 1
orr r9,r9,0x06000000
strh r0,[r9]

cmp r7,0
addgt r3,r3,r4
subgt r7,r7,r5

add r7,r7,r6

cmp r1,r2
add r1,r1,1
bne lineLoop

mainLoop:
b mainLoop:
