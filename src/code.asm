include


write_speed_oam:
;if !version == 1
;	ADC #$0199			;Hijacked instruction
;else
;	ADC #$0166			;Hijacked instruction
;endif
;	STA $0100			;Hijacked instruction
	JSL $84D56F
	PHP
	LDA $36
	CMP #$0002			;Check if we're in a race
	BNE .return 
	LDA !player_kart_speed
	STA !temp_1FD3
	JSR hex_word_to_decimal
	LDA !temp_1FD0			;Retrieve converted speed value
	AND #$F000
	XBA
	LSR
	LSR
	LSR
	LSR
	ASL
	TAY
	LDX #!oam_mirror+$1A0
	LDA #$45D4
	STA $00,x 
	JSR .write_properties  		;Write first digit
	LDA #$45DE
	STA $00,x 
	LDA !temp_1FD0			;Retrieve converted speed value
	AND #$0F00
	XBA
	ASL
	TAY
	JSR .write_properties  		;Write second digit
	LDA !temp_1FD0
	AND #$00F0
	LSR
	LSR
	LSR
	LSR
	ASL
	TAY
	LDA #$45E8
	STA $00,x
	JSR .write_properties  		;Write third digit
	LDA !temp_1FD0
	AND #$000F
	ASL
	TAY
	LDA #$45F2
	STA $00,x
	JSR .write_properties  		;Write fourth digit

;write boost thing
	LDA !player_kart_boost
	CMP #$0080
	BCS .boost_charged
	LDA #$38A7
-:
	STA $02,x
	LDA #$3CE2
	STA $00,x
	LDA !game_mode
	CMP #$0004  			;Check if we're in time trial mode
	BNE .return  			;If not, return
	JSR handle_inputs_oam
.return:
	PLP
	RTL

.boost_charged:
	LDA #$38A8
	BRA -


.write_properties:
	PHB
	PHK
	PLB
	LDA .numbers_oam_properties,y
	STA $02,x
	INX
	INX
	INX
	INX
	PLB
	RTS

.numbers_oam_properties:
	dw $38A7			;0
	dw $38A8			;1
	dw $38A9			;2
	dw $38AA			;3
	dw $38AB			;4
	dw $38B7			;5
	dw $38B8			;6
	dw $38B9			;7
	dw $38BA			;8
	dw $38BB			;9


color_code_speed_disp:
	LDA $000036
	CMP #$0002			;Check if we're in a race
	BNE .return

	SEP #$20
	LDA #$C1
	STA !CGRAM_ADDR

	REP #$20
	LDX !player_character
	LDA.l .top_speeds,x
	CMP !player_kart_speed
	BCC .check_top_2
	LDA #$FFFF
	BRA .write

.check_top_2:
	LDA.l .top_speeds_2,x
	CMP !player_kart_speed
	BCC .orange
.green: 
	LDA #$02C0
	BRA .write

.orange:
	LDA #$023F
.write:
	SEP #$20
	STA !CGRAM_WRITE
	XBA
	STA !CGRAM_WRITE
	REP #$20
.return:	
	LDA $000036			;Hijacked instruction
	TAX				;Hijacked instruction
	RTL


.top_speeds:
if !version == 1
	dw $042D 			;Mario
	dw $042D 			;Luigi
	dw $044D  			;Bowser
	dw $040D 			;Peach
	dw $044D  			;DK Jr
	dw $03FD  			;Koopa Troopa
	dw $03FD  			;Toad
	dw $040D  			;Yoshi
else
	dw $038D 			;Mario
	dw $038D 			;Luigi
	dw $03AD  			;Bowser
	dw $036C 			;Peach
	dw $03AD  			;DK Jr
	dw $035D  			;Koopa Troopa
	dw $035D  			;Toad
	dw $036C  			;Yoshi
endif


.top_speeds_2:
if !version == 1
	dw $0431 			;Mario
	dw $0431 			;Luigi
	dw $0451  			;Bowser
	dw $0411 			;Peach
	dw $0451  			;DK Jr
	dw $0401  			;Koopa Troopa
	dw $0401  			;Toad
	dw $0411  			;Yoshi
else
	dw $0391 			;Mario
	dw $0391 			;Luigi
	dw $03B1  			;Bowser
	dw $0371 			;Peach
	dw $03B1  			;DK Jr
	dw $0360  			;Koopa Troopa
	dw $0360  			;Toad
	dw $0371  			;Yoshi
endif


hex_word_to_decimal:
	PHP
        SED             	; Switch to decimal mode
        SEP #$30
        LDA #$00          	; Ensure the result is clear
        STA !temp_1FD0
        STA !temp_1FD1
        STA !temp_1FD2
        LDX #$06
.loop1:         
        ASL !temp_1FD3       	; Shift out one bit
        ROL !temp_1FD4       	;
	LDA !temp_1FD0       	; And add into result          
        ADC !temp_1FD0       	;
        STA !temp_1FD0       	;
        DEX             	; And repeat for next bit
        BNE .loop1
 
        LDX #$07
.loop2:
        ASL !temp_1FD3       	; Shift out one bit
        ROL !temp_1FD4       	;
        LDA !temp_1FD0       	; And add into result
        ADC !temp_1FD0
        STA !temp_1FD0
        LDA !temp_1FD1       	; propagating any carry
        ADC !temp_1FD1
        STA !temp_1FD1
        DEX             	; And repeat for next bit
        BNE .loop2
 
        LDX #03
.loop3:
        ASL !temp_1FD3       	;Shift out one bit
        ROL !temp_1FD4
        LDA !temp_1FD0       	;And add into result
        ADC !temp_1FD0
        STA !temp_1FD0
        LDA !temp_1FD1       	;propagating any carry
        ADC !temp_1FD1
        STA !temp_1FD1
        LDA !temp_1FD2       	;...thru whole result
        ADC !temp_1FD2
        STA !temp_1FD2
        DEX             	;And repeat for next bit
        BNE .loop3
        CLD             	;Back to binary
	PLP
	RTS 


hex_byte_to_decimal:
	PHP
	CLD
        STA !temp_1FD0       
        LSR
        ADC !temp_1FD0
        ROR
        LSR
        LSR
        ADC !temp_1FD0
        ROR
        ADC !temp_1FD0
        ROR
        LSR
        AND #$3C
        STA !temp_1FD1        
        LSR
        ADC !temp_1FD1
        ADC !temp_1FD0
        PLP
        RTS


upload_ego_text:
if !version == 1
	LDA #$D604
else
	LDA #$D304
endif
	STA !temp_1FD0			;Tile position
	LDY #!oam_mirror+$A0
	LDX #$0000
.loop:
	LDA.l .text_oam_properties,x
	BMI .done
	BEQ .offset_pos
	STA $0002,y
	LDA !temp_1FD0
	STA $0000,y
	INY
	INY
	INY
	INY
.offset_pos:
	LDA !temp_1FD0
	CLC
	ADC #$000A  			;Offset position
	STA !temp_1FD0
	INX
	INX  				;Move to next entry
	BRA .loop

.done:
	LDA $1040			;Hijacked instruction
	CMP #$0642			;Hijacked instruction
	RTL


;A sensible human being would format this horizontally, but not me.
.text_oam_properties:
	dw $3819			;P
	dw $381B			;R
	dw $380A			;A
	dw $380C			;C
	dw $0000
	dw $3811			;H
	dw $380A			;A
	dw $380C			;C
	dw $3814			;K
	dw $0000
	dw $381F			;V
	dw $3801			;1
	dw $3825			;.
	dw $3802			;2
	dw $0000
	dw $380B			;B
	dw $3822			;Y
	dw $0000
	dw $380B			;B
	dw $3815			;L
	dw $381E			;U
	dw $380E			;E
	dw $3812			;I
	dw $3816			;M
	dw $3819			;P
	dw $FFFF



upload_input_display:
	LDA !game_mode
	CMP #$0004  			;Check if we're in time trial mode
	BNE .return  			;If not, return
if !version == 1
	LDX #$BF21  			;Hijacked instruction
	JSL $81950D			;Hijacked instruction
else
	LDX #$C085  			;Hijacked instruction
	JSL $8194F4			;Hijacked instruction
endif
	LDA #$5EE0
	STA !VRAM_ADDR
	LDX #$0020
	LDY #$0000
.write_top_half:
	PHB
	PHK 
	PLB
	LDA input_display_gfx,y
	PLB
	STA !VRAM_WRITE
	INY
	INY
	DEX
	BNE .write_top_half
	LDA #$5FE0
	STA !VRAM_ADDR
	LDX #$0020
	LDY #$0000
.write_bottom_half:
	PHB
	PHK 
	PLB
	LDA input_display_gfx+$40,y
	PLB
	STA !VRAM_WRITE
	INY
	INY
	DEX
	BNE .write_bottom_half
.return:
	RTL


handle_inputs_oam:
	LDY #$0000
	LDX #$0000
.write_positions:
	PHB
	PHK 
	PLB
	LDA inputs_oam_positions,y
	PLB
	STA !oam_mirror+$1C0,x
	INX
	INX
	INX
	INX
	INY
	INY
	CPY #$0014
	BCC .write_positions
	LDY #$0000
	LDX #$0000
.write_properties:
	PHB
	PHK 
	PLB
	LDA inputs_oam_properties,y
	PLB
	PHA
	PHX
	TYA
	TAX
	LDA !player_input_held
	JSR (handle_inputs,x)
	PLX
	PLA
	BCC +
	EOR #$0A00
+:
	STA !oam_mirror+$1C2,x
	INX
	INX
	INX
	INX
	INY
	INY
	CPY #$0014
	BCC .write_properties
	RTS


handle_inputs:
	dw .up
	dw .down
	dw .left
	dw .right
	dw .a
	dw .b
	dw .x
	dw .y
	dw .l
	dw .r


.up:
	BIT #$0800
	BNE .pressed
	CLC
	RTS


.down:
	BIT #$0400
	BNE .pressed
	CLC
	RTS


.left:
	BIT #$0200
	BNE .pressed
	CLC
	RTS


.right:
	BIT #$0100
	BNE .pressed
	CLC
	RTS


.a:
	BIT #$0080
	BNE .pressed
	CLC
	RTS


.b:
	BIT #$8000
	BNE .pressed
	CLC
	RTS


.x:
	BIT #$0040
	BNE .pressed
	CLC
	RTS


.y:
	BIT #$4000
	BNE .pressed
	CLC
	RTS


.l:
	BIT #$0020
	BNE .pressed
	CLC
	RTS


.r:
	BIT #$0010
	BNE .pressed
	CLC
	RTS



.pressed:
	SEC
	RTS





inputs_oam_positions:
	dw $54D6			;Up
	dw $5ED6			;Down
	dw $59D0			;Left
	dw $59DC			;Right

	dw $59F3			;A
	dw $5EEE			;B
	dw $54EE			;X
	dw $59E9			;Y

	dw $4CD6			;L
	dw $4CEE			;R

inputs_oam_properties:
	dw $39EE			;Up
	dw $B9EE			;Down
	dw $79EF			;Left
	dw $A9EF			;Right

	dw $39FF			;A
	dw $39FF			;B
	dw $39FF			;X
	dw $39FF			;Y

	dw $B9FE			;L
	dw $B9FE			;R