
checker_init:

	; start of init process
	ld a, (init_state)
	or a, a
	jr nz, +

        ; reset horizontal scrolling
        ld h, 0x8
        ld l, 4
        call vdp_register_write

        ; line interrupt
        ld h, 0xa
        ld l, 2
        call vdp_register_write

        ; sprites address 0x1a00
        ld h, 5
        ld l, (0x2e << 1) | 1
        call vdp_register_write

        ; palettes
        ld c, VDP_CONTROL_PORT
        ld hl, VDP_WRITE_CRAM
        out (c), l
        out (c), h
        
        ld hl, checker_palette
        ld b, 16
        ld c, VDP_DATA_PORT
        otir

		jp checker_init_done

    +:

	.repeat 8 index count

	cp a, 1 + count
	jr nz, +

		; checker tiles
		ld c, VDP_CONTROL_PORT 
		ld hl, VDP_WRITE_ADDRESS | ((count * 0x800) + 0x0600)
		out (c), l
		out (c), h

		ld c, VDP_DATA_PORT
		ld de, 512
		ld hl, checker_tiles + (count * 512)

		-:
			outi
			dec de
			ld a, d
			or a, e
			jr nz, -
	
		jp checker_init_done

    +:

	.endr

	.repeat 16 index count

	cp a, 1 + 8 + count
	jr nz, +

		; nametable
		; checker tiles
		ld c, VDP_CONTROL_PORT 
		ld de, VDP_WRITE_ADDRESS | (((count >> 1) * 0x800) + ((count & 1) * 0x300))
		out (c), e
		out (c), d

		; 12 rows
		ld c, 12

		--:

			ld b, 16
			ld hl, ((count >> 1) * 64) + 48

			-:
				ld a, l
				out (VDP_DATA_PORT), a
				ld a, h
				out (VDP_DATA_PORT), a
				inc hl
				djnz -

			
			ld b, 16
			dec hl

			-:
				ld a, l
				out (VDP_DATA_PORT), a
				ld a, h
				or a, 0x2
				out (VDP_DATA_PORT), a
				dec hl
				djnz -

			dec c
			jr nz, --

		jp checker_init_done

    +:

	.endr

        ; end of init process
        ; enable display and frame interrupts
        ld h, 1
        ld l, 0b11100000
        call vdp_register_write

        ; vblank call
        ld hl, checker_vblank
        ld (interrupt_call), hl

	checker_init_done:

		; move to next state
		ld a, (init_state)
		inc a
		ld (init_state), a

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