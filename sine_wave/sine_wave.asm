b start

@include header.asm

; function: sine builder
; r0 is input, r2 is flip output flag (0 or 1), r1 is output
; uses Q8.8 fixed point numbers
sineBuilder:
stmfd r13!,{r14}

cmp r0,0x320 ; recurse if input is ~>pi
ble sineBuilderBaseCase

sub r0,r0,0x320
sub r0,r0,0x4
eor r2,r2,1
bl sineBuilder ; recurse with shifted input

ldmfd r13!,{r14}
bx r14

sineBuilderBaseCase:
cmp r0,0x190 ; flip horizontally if input is ~>pi/2
movgt r1,0x320
orrgt r1,r1,0x4
subgt r1,r1,r0
bgt endSineBuilderInAdjust

mov r1,r0

endSineBuilderInAdjust:
mov r0,r1
bl sinePart

cmp r2,1
;mvneq r1,r0
moveq r0,0
subeq r1,r0,r1

endSineBuiler:
ldmfd r13!,{r14}
bx r14

; function: approximate sine from 0 to pi/2
; r0 is x, return y on r1
; uses Q8.8 fixed point numbers
sinePart:
stmfd r13!,{r2-r3,r14}

add r1,r0,23

mul r2,r1,r1
mov r2,r2 lsr 11
mov r3,0x100
sub r2,r3,r2
mul r2,r2,r1
mov r2,r2 lsr 8
sub r1,r2,23

ldmfd r13!,{r2-r3,r14}
bx r14

start:
mov r0,0x4000000
mov r1,0x400
orr r1,r1,0x3
strh r1,[r0]

; iterate over every x and draw
mvn r3,0 ; color
mov r4,0x1E0

mov r5,0
loopX:
mov r0,r5 lsl 3 ; horizontal scale
mov r2,1 ; flip sine wave
bl sineBuilder

; vertical shift and scale
add r1,r1,0x140
mov r1,r1 lsr 2

; draw point
mla r0,r1,r4,r5
orr r0,r0,0x6000000
strh r3,[r0]

add r5,r5,2

cmp r5,0x1E0
blt loopX

loop:
b loop
