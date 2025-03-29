
gradient_vblank:

	; increment timer
	ld hl, (tic)
	inc hl
	ld (tic), hl

	; check if we're done with this effect
	ld de, TIC_GRADIENT_DONE
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
		ld hl, spotlight_vblank
		ld (interrupt_call), hl
		jp gradient_vblank_done

	+:

    ; line interrupt
    ld h, 0xa
    ld l, 1
    call vdp_register_write

	; mode 4, line interrupts on
	ld h, 0
	ld l, 0b00110110
	call vdp_register_write

    ; use hblank interrupt call
	ld hl, gradient_hblank
	ld (interrupt_call), hl

	gradient_vblank_done:

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

gradient_hblank:

    ; nametable register byte
    ld l, 0xf1

    ; first bar
    ld a, (tic)

    ; reverse direction if bit 7 set
    bit 7, a
    jr z, +

        neg
        add a, 0x7f

    +:
    and a, 0x7f

    ; top and bottom of bar
    add a, 8
    ld b, a
    add a, 48
    ld c, a

    ; check if current line is within the bar
    in a, (0x7e)
    cp a, b
    jr c, + 

        cp a, c
        jr nc, +

            ; nametable bit 2
            set 2, l

    +:

    ; second bar goes twice as fast
    ld a, (tic)
    rla

    ; reverse direction if bit 7 set
    bit 7, a
    jr z, +

        neg
        add a, 0x7f

    +:
    and a, 0x7f

    ; top and bottom of bar
    add a, 8
    ld b, a
    add a, 48
    ld c, a

    ; check if current line is within the bar
    in a, (0x7e)
    cp a, b
    jr c, + 

        cp a, c
        jr nc, +

            ; nametable bit 1
            set 1, l

    +:

    ld h, 2
    call vdp_register_write

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
		ld hl, gradient_vblank
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