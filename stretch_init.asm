
stretch_init:

	; start of init process
	ld a, (init_state)
	or a, a
	jr nz, +
		
		; write palettes
		ld c, VDP_CONTROL_PORT
		ld hl, VDP_WRITE_CRAM
		out (c), l
		out (c), h
		
		ld hl, text_palette
		ld b, 16
		ld c, VDP_DATA_PORT
		otir

		; disable sprites
		ld c, VDP_CONTROL_PORT 
		ld hl, VDP_WRITE_ADDRESS | 0x3f00
		out (c), l
		out (c), h

		ld a, 0xd0
		ld c, VDP_DATA_PORT
		out (c), a

		; sprites address 0x3f00
		ld h, 5
		ld l, 0xff
		call vdp_register_write

		jp stretch_init_done

	+:
	cp a, 1
	jr nz, +

		; text tiles
		ld c, VDP_CONTROL_PORT 
		ld hl, VDP_WRITE_ADDRESS | 0x3000
		out (c), l
		out (c), h

		ld c, VDP_DATA_PORT
		ld de, _sizeof_text_tiles
		ld hl, text_tiles

		-:
			outi
			dec de
			ld a, d
			or a, e
			jr nz, -

		jp stretch_init_done
	
	+:

	; break up loading so that it will
	; load 12 rows of nametable each frame
	.repeat 12 index count
	cp a, count + 2
	jr nz, +

		; text nametable
		ld c, VDP_CONTROL_PORT 
		ld de, VDP_WRITE_ADDRESS | (((count >> 1) * 0x800) + ((count & 1) * 0x300))
		out (c), e
		out (c), d

		; 12 rows
		ld c, 12

		--:

			ld b, 64
			ld hl, text_tilemap + ((count >> 1) * 64)

			-:
				ld a, (hl)
				out (VDP_DATA_PORT), a
				inc hl
				djnz -

			dec c
			jr nz, --


		jp stretch_init_done

	+:
	.endr

		; end of init process
		; default to "empty" nametable
		ld h, 0x2
		ld l, 0xf1 | (5 << 1)
		call vdp_register_write

		; enable display and frame interrupts
		ld h, 1
		ld l, 0b11100000
		call vdp_register_write

		; vblank call
		ld hl, stretch_vblank
		ld (interrupt_call), hl

	stretch_init_done:

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
