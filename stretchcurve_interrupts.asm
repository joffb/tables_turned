

stretchcurve_vblank:

    ; increment timer
	ld hl, (tic)
	inc hl
	ld (tic), hl

	; check if we're done with this effect
	ld de, TIC_STRETCHCURVE_DONE
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
		ld hl, gradient_init
		ld (interrupt_call), hl
		jp stretch_vblank_done

	+:

    ; enable display and frame interrupts
    ld h, 1
    ld l, 0b11100000
    call vdp_register_write

	; reset horizontal scrolling
	ld h, 0x8
	ld l, 12
	call vdp_register_write

	; mode 4, line interrupts on
	ld h, 0
	ld l, 0b00110110
	call vdp_register_write

	; use hblank interrupt call
	ld hl, stretchcurve_hblank
	ld (interrupt_call), hl

    ld a, (tic)
    neg
    and a, 0xf
    or a, <stretchcurve_nametables
    ld e, a
    ld d, >stretchcurve_nametables

    ld hl, stretchcurve_sizes

	; get nametable register value and write it
	; to the register
	ld a, (de)
    inc de
	out (VDP_CONTROL_PORT), a
	ld a, 2 | >VDP_WRITE_REGISTER
	out (VDP_CONTROL_PORT), a

	; get line counter value and write it
	; to the register
	ld a, (hl)
    inc hl
	out (VDP_CONTROL_PORT), a
	ld a, 0xa | >VDP_WRITE_REGISTER
	out (VDP_CONTROL_PORT), a

    ; preserve lower byte of counter pointer in d
    ld d, l

	stretchcurve_vblank_done:

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


stretchcurve_hblank:

    ; restore lower byte of counter pointer from d
    ; and restore the upper bytes of pointers
    ld l, d
    ld h, >stretchcurve_sizes
    ld d, >stretchcurve_nametables

	; get nametable register value and write it
	; to the register
	ld a, (de)
	out (VDP_CONTROL_PORT), a
	ld a, 0x2 | >VDP_WRITE_REGISTER
	out (VDP_CONTROL_PORT), a

	; get line counter value and write it
	; to the register
	ld a, (hl)
	out (VDP_CONTROL_PORT), a
	ld a, 0xa | >VDP_WRITE_REGISTER
	out (VDP_CONTROL_PORT), a

    ; wrap nametable index
    bit 4, l
    jr z, +
        inc de
        jr ++
    +:
    dec de
    ++:
    ld a, e
    and a, 0xf
    or a, <stretchcurve_nametables
    ld e, a

    ld a, l
    and a, 0x1f
    cp a, 0x1f
    jr z, +

        ; move line counter index
        inc hl

    +:

    ; preserve lower byte of counter pointer in d
    ld d, l

	; if we're just at the end of the frame
	; switch back to the vblank handler and disable hblank interrupts
	in a, (0x7e)
	cp a, 188
	jr c, +

		; mode 4, line interrupts off
		ld h, 0
		ld l, 0b00100110
		call vdp_register_write

		; use hblank interrupt call
		ld hl, stretchcurve_vblank
		ld (interrupt_call), hl

	+:

	stretchcurve_hblank_done:

		; acknowledge interrupt
		ld c, VDP_CONTROL_PORT
		in a, (c)

		; done
		exx
		ex af, af'
		
		ei
		reti