include

;Ver. 0 = NTSC, 1 = PAL


if !version == 1
	hijack_NMI = $808011
	hijack_title_screen_something = $808547
	hijack_timer_update = $80A07C
	hijack_special_course_check_1 = $81C63C
	hijack_special_course_check_2 = $84F9BB
	hijack_special_course_check_3 = $84FA23
	hijack_special_course_check_4 = $84F5E8
else
	hijack_NMI = $808011
	hijack_title_screen_something = $808547
	hijack_timer_update = $80A071
	hijack_special_course_check_1 = $81C7A0
	hijack_special_course_check_2 = $84FAA2
	hijack_special_course_check_3 = $84FB0A
	hijack_special_course_check_4 = $84F6CF
endif




org hijack_NMI
	JSL color_thing
	NOP

org hijack_title_screen_something
	JSL upload_ego_text
	WDM


org hijack_timer_update
	JSL write_speed_oam
	WDM


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