b start

@include header.asm

palette:
@DCW %0111111101101110
@DCW %0000110100101101
@DCW %0010010111010010
@DCW %0000011011000101
@DCW %0001001000000110
@DCW %0000100011001000
@DCW %0001111101101011
@DCW %0100001000010001

tiles:
; top grass - 1
@DCD 0x33663366
@DCD 0x33363333
@DCD 0x43334434
@DCD 0x54445545
@DCD 0x15554151
@DCD 0x21121711
@DCD 0x71111121
@DCD 0x11711111

; edge grass left - 2
@DCD 0x33333660
@DCD 0x34663336
@DCD 0x45444333
@DCD 0x52555463
@DCD 0x11111543
@DCD 0x17117143
@DCD 0x11211154
@DCD 0x11111715

; edge grass right - 3
@DCD 0x06336333
@DCD 0x63333663
@DCD 0x63364433
@DCD 0x33445544
@DCD 0x64557155
@DCD 0x45711121
@DCD 0x45121111
@DCD 0x51111711

; dirt - 4
@DCD 0x11111111
@DCD 0x11111711
@DCD 0x12111112
@DCD 0x11111111
@DCD 0x11112111
@DCD 0x11711111
@DCD 0x11111171
@DCD 0x11121111

; 0 horiz log top - 5
@DCD 0x11111111
@DCD 0x22222222
@DCD 0x22111211
@DCD 0x22222222
@DCD 0x11221112
@DCD 0x22222222
@DCD 0x22111222
@DCD 0x12222211

; 1 horiz log - 6
@DCD 0x11111111
@DCD 0x22222222
@DCD 0x12211211
@DCD 0x22222222
@DCD 0x21112222
@DCD 0x22222112
@DCD 0x11122222
@DCD 0x11111111

; 1 vert log - 7
@DCD 0x12122121
@DCD 0x12212121
@DCD 0x11212221
@DCD 0x11212221
@DCD 0x11222121
@DCD 0x12222121
@DCD 0x12121221
@DCD 0x12122221

; horiz log center - 8
@DCD 0x22222222
@DCD 0x11122222
@DCD 0x22222111
@DCD 0x22222222
@DCD 0x21112222
@DCD 0x22222222
@DCD 0x12222211
@DCD 0x22111222

; 0 horiz log bottom - 9
@DCD 0x22222222
@DCD 0x22211112
@DCD 0x11222222
@DCD 0x22221111
@DCD 0x22222222
@DCD 0x12111221
@DCD 0x22222222
@DCD 0x11111111

map:
@DCB 0x00,0x07,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
@DCB 0x05,0x08,0x05,0x05,0x00,0x00,0x00,0x00,0x00,0x00,0x00
@DCB 0x09,0x09,0x09,0x09,0x00,0x06,0x06,0x06,0x00,0x02,0x03
@DCB 0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x04,0x04
@DCB 0x04,0x04,0x04,0x04,0x04,0x04,0x04,0x04,0x04,0x04,0x04

start:
mov r0,0x4000000
mov r1,%0000000100000000 ; turn on BG0 screen and use BG mode 0
strh r1,[r0]

mov r1,%0000000100000000 ; set BG0 screen base block to 1
strh r1,[r0,0x8]

transferPalette:
	addr r1,palette
	str r1,[r0,0xD4]

	mov r1,0x5000000
	str r1,[r0,0xD8]

	mov r1,(%10000100000 << 21) ; do DMA transfer (32-bit)
	orr r1,r1,4 ; do 4 transfers
	str r1,[r0,0xDC]

transferTiles:
	addr r1,tiles
	str r1,[r0,0xD4]

	; background
	mov r1,0x6000000
	orr r2,r1,0x20 ; skip tile0
	str r2,[r0,0xD8]

	mov r2,(%10000100000 << 21) ; do DMA transfer (32-bit)
	orr r2,r2,(8 * 9) ; do (8 tile lines * 9 tiles) transfers
	str r2,[r0,0xDC]

transferMap:
	orr r1,r1,(0x800 + 0x40) ; start in second row: 0x40 offset from 0x6000800
	add r5,r1,(0x40 * 5) ; 40 bytes per row * 5 rows

	addr r2,map

	mapTransferLoop:
		ldrb r3,[r2],1
		strh r3,[r1],2

		and r4,r1,%11111
		cmp r4,(11 * 2) ; 11 tiles wide * 2 bytes per halfword
		blt mapTransferLoop
		add r1,r1,(0x40 - (11 * 2)) ; 40 bytes per row * (11 tiles wide * 2 bytes per halfword)
		cmp r1,r5
		bne mapTransferLoop

loop:
b loop
