
.include "../banjo_git/banjo/music_driver/banjo_defines_wladx.inc"

.define VDP_CONTROL_PORT 0xbf
.define VDP_DATA_PORT 0xbe

.define VDP_WRITE_ADDRESS 0x4000
.define VDP_WRITE_CRAM 0xc000
.define VDP_WRITE_REGISTER 0x8000

.define IO_PORT_A_B 0xdc

; nametable address 0x3000
.define NAMETABLE_3000 0b11111101
; nametable address 0x3800
.define NAMETABLE_3800 0b11111111


.define TIC_STRETCH_DONE 512
.define TIC_STRETCHCURVE_DONE 512
.define TIC_GRADIENT_DONE 600
.define TIC_SPOTLIGHT_DONE 600
.define TIC_CHECKER_DONE 1000


.MEMORYMAP
	SLOTSIZE $4000
	DEFAULTSLOT 0
	SLOT 0 $0000			; ROM slot 0.
	SLOT 1 $4000			; ROM slot 1.
	SLOT 2 $8000			; ROM slot 2
	SLOT 3 $C000			; RAMl
.ENDME

.ROMBANKMAP
	BANKSTOTAL 2
	BANKSIZE $4000
	BANKS 2
.ENDRO

.ramsection "Vars" slot 3

	bios: db

	spot_x: db
	spot_y: db

	tic: dw
	interrupt_call: dw

	nametable_ptr: db

	vblank_done: db

	init_state: db

	song_channels: INSTANCEOF channel (CHAN_COUNT_SN)
	song_channel_ptrs: ds (CHAN_COUNT_SN * 2)

.ends

.org 0x0000
	di
	im 1
	jp init

; vdp vblank/hblank interrupt
.org 0x0038

	ex af, af'
	exx
	
	ld hl, (interrupt_call)
	jp (hl)
	

.org 0x0066
	retn

init:

	; set Stack pointer
	ld sp, 0xdf00
	
	; clear tic timer
	ld hl, 0
	ld (tic), hl

	; overscan colour
	ld h, 7
	ld l, 0
	call vdp_register_write

	; nametable address 0x3800
	ld h, 2
	ld l, 0xff
	call vdp_register_write

	; use second set of tiles for sprites
	ld h, 6
	ld l, 0xff
	call vdp_register_write

	; mode 4, line interrupts off
	ld h, 0
	ld l, 0b00100110
	call vdp_register_write

	; disable display, enable frame interrupts
	ld h, 1
	ld l, 0b10100000
	call vdp_register_write

	; prepare to load 
	xor a, a
	ld (init_state), a

	ld hl, stretch_init
	ld (interrupt_call), hl

	xor a, a
	ld (vblank_done), a

	call banjo_check_hardware

	; initialise channels
	ld a, CHAN_COUNT_SN
	ld l, BANJO_HAS_SN
	call banjo_init

	ld hl, tune
	call banjo_play_song
	
	ei

	main_done:

		halt

		; check for vblank
		-:		
			ld a, (vblank_done)
			or a, a
			jr z, -

		; clear vblank flag
		xor a, a
		ld (vblank_done), a

		call banjo_update_song

		jr main_done




; h: register
; l: value
vdp_register_write:

	ld a, l
	out (VDP_CONTROL_PORT), a

	ld a, h
	or a, >VDP_WRITE_REGISTER
	out (VDP_CONTROL_PORT), a
	
	ret


; spotlight
.include "spotlight_macros.inc"
.include "spotlight_interrupts.asm"

.align 256
spotlight_sine:
.include "spotlight_sine.inc"

.BANK 1
.SLOT 1
.org 0x0000

; checkerboard
.include "checker_init.asm"
.include "checker_interrupts.asm"

checker_tilemap:
.incbin "assets/checker_map.bin"

checker_palette:
.incbin "assets/checker_pal.bin"

checker_tiles:
.incbin "assets/checker_tiles.bin"
checker_tiles_end:

.align 256
nametable_sine:
.include "nametable_sine.inc"

; text stretch
.include "stretch_init.asm"
.include "stretch_interrupts.asm"
.include "stretchcurve_interrupts.asm"

text_tilemap:
.incbin "assets/text_map.bin"

text_palette:
.incbin "assets/text_pal.bin"

text_tiles:
.incbin "assets/text_tiles.bin"
text_tiles_end:

.align 256
nametable_stretch:
.include "nametable_stretch.inc"
.align 32
.include "nametable_stretchcurve.inc"


; gradient
.include "gradient_init.asm"
.include "gradient_interrupts.asm"

gradient_tilemap:
.incbin "assets/gradient_map.bin"

gradient_palette:
.incbin "assets/gradient_pal.bin"

gradient_tiles:
.incbin "assets/gradient_tiles.bin"
gradient_tiles_end:

; music!
.include "music/tune.asm"

.SMSHEADER
    PRODUCTCODE 26, 70, 2 ; 2.5 bytes
    VERSION 1             ; 0-15
    REGIONCODE 4          ; 3-7
    RESERVEDSPACE 0, 0    ; 2 bytes
    ROMSIZE 0xc            ; 0-15
    CHECKSUMSIZE 32*1024  ; Uses the first this-many bytes in checksum
                          ;   calculations (excluding header area)
.ENDSMS