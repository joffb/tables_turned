
gradient_init:

	; start of init process
	ld a, (init_state)
	or a, a
	jr nz, +

		; default to first nametable
		ld h, 0x2
		ld l, 0xf1 | (0 << 1)
		call vdp_register_write

        ; reset horizontal scrolling
        ld h, 0x8
        ld l, 4
        call vdp_register_write

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

        ; palettes
        ld c, VDP_CONTROL_PORT
        ld hl, VDP_WRITE_CRAM
        out (c), l
        out (c), h
        
        ld hl, gradient_palette
        ld b, 32
        ld c, VDP_DATA_PORT
        otir

		jp gradient_init_done

    +:

	cp a, 1
	jr nz, +

		; checker tiles
		ld c, VDP_CONTROL_PORT 
		ld hl, VDP_WRITE_ADDRESS | 0x3000
		out (c), l
		out (c), h

		ld c, VDP_DATA_PORT
		ld de, _sizeof_gradient_tiles
		ld hl, gradient_tiles

		-:
			outi
			dec de
			ld a, d
			or a, e
			jr nz, -
	
		jp gradient_init_done

    +:

	cp a, 2
	jr nz, +

		; text nametable
		ld c, VDP_CONTROL_PORT 
		ld de, VDP_WRITE_ADDRESS | 0x0000
		out (c), e
		out (c), d

        ld hl, gradient_tilemap

		; 12 rows
		ld e, 12

		--:

			ld b, 64
            ld c, VDP_DATA_PORT
			
			-:
                ld a, (hl)
                out (c), a
                inc hl
                ld a, (hl)
                out (c), a
                inc hl

                djnz -

			dec e
			jr nz, --

		jp gradient_init_done

    +:

	cp a, 3
	jr nz, +

		; text nametable
		ld c, VDP_CONTROL_PORT 
		ld de, VDP_WRITE_ADDRESS | (0x0300)
		out (c), e
		out (c), d

		; 12 rows
		ld e, 12

		--:

			ld b, 64
            ld c, VDP_DATA_PORT
            ld hl, gradient_tilemap
			otir

			dec e
			jr nz, --

		jp gradient_init_done

    +:

    ; nametable 1
	cp a, 4
	jr nz, +

		; text nametable
		ld c, VDP_CONTROL_PORT 
		ld de, VDP_WRITE_ADDRESS | (0x800)
		out (c), e
		out (c), d

        ld hl, gradient_tilemap

		; 12 rows
		ld e, 12

		--:

			ld b, 32
            ld c, VDP_DATA_PORT
			
			-:
                ld a, (hl)
                out (c), a
                inc hl
                ld a, (hl)
                or a, 0x8
                out (c), a
                inc hl

                djnz -

			dec e
			jr nz, --

		jp gradient_init_done


    +:

	cp a, 5
	jr nz, +

		; text nametable
		ld c, VDP_CONTROL_PORT 
		ld de, VDP_WRITE_ADDRESS | (0x800 + 0x300)
		out (c), e
		out (c), d

		; 12 rows
		ld e, 12

		--:

			ld b, 32
            ld c, VDP_DATA_PORT
            ld hl, gradient_tilemap
			
			-:
                ld a, (hl)
                out (c), a
                inc hl
                ld a, (hl)
                or a, 0x8
                out (c), a
                inc hl

                djnz -

			dec e
			jr nz, --

		jp gradient_init_done

    +:

    ; nametable 2
	cp a, 6
	jr nz, +

		; text nametable
		ld c, VDP_CONTROL_PORT 
		ld de, VDP_WRITE_ADDRESS | (0x1000)
		out (c), e
		out (c), d

        ld hl, gradient_tilemap + 768

		; 12 rows
		ld e, 12

		--:

			ld b, 32
            ld c, VDP_DATA_PORT
			
			-:
                ld a, (hl)
                inc hl
                out (c), a

                ld a, (hl)
                inc hl
                out (c), a

                djnz -

			dec e
			jr nz, --

		jp gradient_init_done

    +:

	cp a, 7
	jr nz, +

		; text nametable
		ld c, VDP_CONTROL_PORT 
		ld de, VDP_WRITE_ADDRESS | (0x1000 + 0x300)
		out (c), e
		out (c), d

		; 12 rows
		ld e, 12

		--:

			ld b, 32
            ld c, VDP_DATA_PORT
            ld hl, gradient_tilemap + 768
			
			-:
                ld a, (hl)
                inc hl
                out (c), a

                ld a, (hl)
                inc hl
                out (c), a

                djnz -

			dec e
			jr nz, --

		jp gradient_init_done

    +:

    ; nametable 3

	cp a, 8
	jr nz, +

		; text nametable
		ld c, VDP_CONTROL_PORT 
		ld de, VDP_WRITE_ADDRESS | 0x1800
		out (c), e
		out (c), d

        ld hl, gradient_tilemap + 768

		; 12 rows
		ld e, 12

		--:

			ld b, 32
            ld c, VDP_DATA_PORT
			
			-:
                ld a, (hl)
                inc hl
                out (c), a

                ld a, (hl)
                or a, 0x8
                inc hl
                out (c), a

                djnz -

			dec e
			jr nz, --

		jp gradient_init_done

    +:

	cp a, 9
	jr nz, +

		; text nametable
		ld c, VDP_CONTROL_PORT 
		ld de, VDP_WRITE_ADDRESS | (0x1800 + 0x300)
		out (c), e
		out (c), d

		; 12 rows
		ld e, 12

		--:

			ld b, 32
            ld c, VDP_DATA_PORT
			ld hl, gradient_tilemap + 768

			-:
                ld a, (hl)
                inc hl
                out (c), a

                ld a, (hl)
                or a, 0x8
                inc hl
                out (c), a

                djnz -

			dec e
			jr nz, --

		jp gradient_init_done

    +:

        ; end of init process
        ; enable display and frame interrupts
        ld h, 1
        ld l, 0b11100000
        call vdp_register_write

        ; vblank call
        ld hl, gradient_vblank
        ld (interrupt_call), hl

	gradient_init_done:

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