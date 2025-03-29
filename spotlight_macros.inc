

.macro GAP_24
	; nametable address 0x3000
	out (c), d
	out (c), a

	nop
	nop
	nop
	nop
	nop
	nop

	; nametable address 0x3800
	out (c), e
	out (c), a
.endm

.macro GAP_16

	nop

	; nametable address 0x3000
	out (c), d
	out (c), a

	nop
	nop
	nop
	nop

	; nametable address 0x3800
	out (c), e
	out (c), a

	nop

.endm

.macro GAP_12
	inc hl

	; nametable address 0x3000
	out (c), d
	out (c), a

	nop
	nop
	nop

	; nametable address 0x3800
	out (c), e
	out (c), a

	dec hl
.endm

.macro GAP_8
	nop
	nop

	; nametable address 0x3000
	out (c), d
	out (c), a

	nop
	nop

	; nametable address 0x3800
	out (c), e
	out (c), a

	nop
	nop
.endm

.macro GAP_6
	nop
	inc hl

	; nametable address 0x3000
	out (c), d
	out (VDP_CONTROL_PORT), a

	inc hl

	; nametable address 0x3800
	out (c), e
	out (VDP_CONTROL_PORT), a

	dec hl
	nop
.endm

.macro GAP_4
	nop
	inc hl

	; nametable address 0x3000
	out (c), d
	out (c), a

	nop

	; nametable address 0x3800
	out (c), e
	out (c), a

	dec hl
	nop
.endm


.macro GAP_0

	nop
	nop
	nop

	; nametable address 0x3000
	out (c), d
	out (c), a

	; nametable address 0x3800
	out (c), e
	out (c), a

	nop
	nop
	nop

.endm

; 156 clocks
.macro POST_GAP_DELAY
	inc hl
	dec hl
	inc hl
	dec hl
	inc hl
	push hl
	pop hl
	push hl
	pop hl
	push hl
	pop hl
	push hl
	pop hl
	push hl
	pop hl
	push hl
	pop hl
.endm