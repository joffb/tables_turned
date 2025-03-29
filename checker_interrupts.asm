
checker_vblank:

	; increment timer
	ld hl, (tic)
	inc hl
	ld (tic), hl
	
	; check if we're done with this effect
	ld de, TIC_CHECKER_DONE
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
		ld hl, stretch_init
		ld (interrupt_call), hl
		jp checker_vblank_done

	+:

	ld a, (tic)
	ld b, a

	rl a
	rl a

	ld d, >nametable_sine
	ld e, a

	; get nametable register value and write it
	; to the register
	ld a, (de)
	out (VDP_CONTROL_PORT), a
	ld a, 2 | >VDP_WRITE_REGISTER
	out (VDP_CONTROL_PORT), a

	inc e

	; mode 4, line interrupts on
	ld h, 0
	ld l, 0b00110110
	call vdp_register_write

	; use hblank interrupt call
	ld hl, checker_hblank
	ld (interrupt_call), hl

	checker_vblank_done:

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


checker_hblank:

	; get nametable register value and write it
	; to the register
	ld a, (de)
	out (VDP_CONTROL_PORT), a
	ld a, 2 | >VDP_WRITE_REGISTER
	out (VDP_CONTROL_PORT), a
	
	; palette
	ld a, 13
	out (VDP_CONTROL_PORT), a
	ld a, >VDP_WRITE_CRAM
	out (VDP_CONTROL_PORT), a

	nop
	nop
	nop

	; move on nametable sine pointer in de
	ld a, e
	add a, 3
	ld e, a

	; get current line and add tic to it
	in a, (0x7e)
	;add a, b
	sub a, b

	; different colours every 32 lines
	and a, 0x20
	jr nz, +

		ld a, 0x10
		out (VDP_DATA_PORT), a

		nop

		ld a, 0x3c
		out (VDP_DATA_PORT), a

		jp ++

	+:

		ld a, 0x3c
		out (VDP_DATA_PORT), a

		nop

		ld a, 0x10
		out (VDP_DATA_PORT), a

	++:

	; if we're just at the end of the frame
	; switch back to the vblank handler and disable hblank interrupts
	in a, (0x7e)
	cp a, 190
	jr c, +

		; mode 4, line interrupts off
		ld h, 0
		ld l, 0b00100110
		call vdp_register_write

		; use hblank interrupt call
		ld hl, checker_vblank
		ld (interrupt_call), hl

	+:

	; acknowledge interrupt
	ld c, VDP_CONTROL_PORT
	in a, (c)

	; done
	exx
	ex af, af'
	
	ei
	reti

