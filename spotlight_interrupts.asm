

spotlight_vblank:

	; enable display and frame interrupts
	ld h, 1
	ld l, 0b11100000
	call vdp_register_write

	ld hl, (tic)
	inc hl
	ld (tic), hl

	; check if we're done with this effect
	ld de, TIC_SPOTLIGHT_DONE
	sbc hl, de
	jr c, +

		; reset timer
		ld hl, 0
		ld (tic), hl

		; disable display, enable frame interrupts
		ld h, 1
		ld l, 0b10100000
		call vdp_register_write

		; init state == 0
		xor a, a
		ld (init_state), a

		; interrupt which loads the tiles/tilemaps
		ld hl, checker_init
		ld (interrupt_call), hl
		jp stretch_vblank_done

	+:

	; get spotlight y coord
	ld h, >spotlight_sine
	ld a, (hl)
	rla
	rla
	add a, 16
	ld (spot_y), a

	; get spotlight x coord
	ld a, l
	add a, 64
	add a, a
	ld l, a
	ld a, (hl)
	add a, 8
	ld (spot_x), a

	; mode 4, line interrupts on
	ld h, 0
	ld l, 0b00110110
	call vdp_register_write

	; line interrupt start
	ld h, 0xa
	ld a, (spot_y)
	ld l, a
	call vdp_register_write
	
	; spotlight_hblank starts off with a load of NOPs
	; set this so we jump to (spotlight_hblank + horizontal_position)
	; to give a different start delay
	ld a, (spot_x)
	neg
	add a, 64
	add a, <spotlight_hblank
	ld l, a
	adc a, >spotlight_hblank
	sub a, l
	ld h, a

	ld (interrupt_call), hl

	; acknowledge interrupt
	ld c, VDP_CONTROL_PORT
	in a, (c)

	; set vblank flag
	ld a, 1
	ld (vblank_done), a

	; done
	exx
	ex af, af'
	
	ei
	reti



spotlight_hblank:

	.rept 64
	nop
	.endr

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
	nop
	nop
	nop
	
	ld a, >VDP_WRITE_REGISTER | 2
	ld c, VDP_CONTROL_PORT

	; nametable address 0x1800
	ld d, 0xf7
	; nametable address 0x0000
	ld e, 0xf1
	
	.rept 2
	GAP_0
	POST_GAP_DELAY
	.endr

	.rept 2
	GAP_4
	POST_GAP_DELAY
	.endr

	.rept 2
	GAP_6
	POST_GAP_DELAY
	.endr

	.rept 3
	GAP_8
	POST_GAP_DELAY
	.endr

	.rept 4
	GAP_12
	POST_GAP_DELAY
	.endr

	.rept 6
	GAP_16
	POST_GAP_DELAY
	.endr

	.rept 24
	GAP_24
	POST_GAP_DELAY
	.endr

	.rept 6
	GAP_16
	POST_GAP_DELAY
	.endr

	.rept 3
	GAP_12
	POST_GAP_DELAY
	.endr

	.rept 3
	GAP_8
	POST_GAP_DELAY
	.endr
	
	.rept 2
	GAP_6
	POST_GAP_DELAY
	.endr
	
	.rept 2
	GAP_4
	POST_GAP_DELAY
	.endr

	.rept 2
	GAP_0
	POST_GAP_DELAY
	.endr

	; mode 4, line interrupts off
	ld h, 0
	ld l, 0b00100110
	call vdp_register_write


	ld hl, spotlight_vblank
	ld (interrupt_call), hl
	
	; acknowledge interrupt
	ld c, VDP_CONTROL_PORT
	in a, (c)

	; done
	exx
	ex af, af'
	
	ei
	reti
