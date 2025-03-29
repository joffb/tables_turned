
stretch_hblank:

	; waste some time so we don't update mid-line
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
	
	ex de, hl

	; set nametable location
	outi
	outi
	
	; set line counter
	outi
	outi

	ex de, hl

	; have we done all of the line interrupts for this frame?
	ld a, e
	and a, 31
	jr nz, +

		; mode 4, line interrupts off
		ld h, 0
		ld l, 0b00100110
		call vdp_register_write

		; use vblank interrupt call
		ld hl, stretch_vblank
		ld (interrupt_call), hl

	+:

	; acknowledge interrupt
	in a, (c)

	exx
	ex af, af'
	
	ei
	reti

stretch_vblank:

	; increment timer
	ld hl, (tic)
	inc hl
	ld (tic), hl
	
	; check if we're done with this effect
	ld de, TIC_STRETCH_DONE
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
		ld hl, stretchcurve_vblank
		ld (interrupt_call), hl
		jp stretch_vblank_done

	+:

	; horizontal scrolling
	ld a, (tic)
	neg
	ld h, 0x8
	ld l, a
	call vdp_register_write

	; check if tic & 0x40
	ld a, (tic)
	bit 6, a
	jr z, +

		; if it is we want to shrink, so invert the value
		neg
		add a, 0x3f

	+:

	; get offset into nametable_stretch
	; a = a * 4
	and a, 0x3f
	add a, a
	add a, a

	; hl = a
	; hl = hl * 8
	ld h, 0
	ld l, a
	add hl, hl
	add hl, hl
	add hl, hl

	; index into nametable_stretch
	ld de, nametable_stretch
	add hl, de

	ld c, VDP_CONTROL_PORT 

	; set nametable location
	outi
	outi
	
	; set line counter
	outi
	outi

	; keep pointer in de
	ex de, hl

	; mode 4, line interrupts on
	ld h, 0
	ld l, 0b00110110
	call vdp_register_write

	; use hblank interrupt call
	ld hl, stretch_hblank
	ld (interrupt_call), hl

	stretch_vblank_done:

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
