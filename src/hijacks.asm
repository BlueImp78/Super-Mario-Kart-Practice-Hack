include

;Ver. 0 = NTSC, 1 = PAL


if !version == 1
	hijack_NMI = $808011
	hijack_title_screen_timer = $808547
	hijack_thing_1 = $808092 ;$80A07C
	hijack_course_select_dma = $81BEB5
	hijack_special_course_check_1 = $81C63C
	hijack_special_course_check_2 = $84F9BB
	hijack_special_course_check_3 = $84FA23
	hijack_special_course_check_4 = $84F5E8
else
	hijack_NMI = $808011
	hijack_title_screen_timer = $808547
	hijack_thing_1 = $808092 ;$80A071
	hijack_course_select_dma = $81C019
	hijack_special_course_check_1 = $81C7A0
	hijack_special_course_check_2 = $84FAA2
	hijack_special_course_check_3 = $84FB0A
	hijack_special_course_check_4 = $84F6CF
endif




org hijack_NMI
	JSL color_code_speed_disp
	NOP

org hijack_title_screen_timer
	JSL upload_ego_text
	WDM

org hijack_course_select_dma
	JSL upload_input_display
	NOP #3


org hijack_thing_1
	JSL write_speed_oam
	;WDM


;Enable special course always in time trial
org hijack_special_course_check_1
	BRA $0A
	WDM


;Enable special course always in gp mode (bottom select)
org hijack_special_course_check_2
	BRA $22
	WDM


;Enable special course always in gp mode (top wrap to bottom select)
org hijack_special_course_check_3
	BRA $2B
	NOP


;Special course always colored in gp mode
org hijack_special_course_check_4
	BRA $22
	WDM