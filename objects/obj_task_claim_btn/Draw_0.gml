if not disabled{
	sprite_index = spr_task_claim_btn
	if on_click{
		image_index = 1
	}
	else{
		image_index = 0
	}
}
else{
	sprite_index = spr_task_claim_btn_disabled
	image_index = 0
}
draw_self()