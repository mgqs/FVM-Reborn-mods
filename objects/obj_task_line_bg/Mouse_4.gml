if obj_task_bg.target_task_index != btn_index{
	var task_id = obj_task_bg.current_task_list[btn_index].id
	if get_task_state(task_id) == "new"{
		edit_task_state(task_id,"viewed")
	}
	obj_task_bg.target_task_index = btn_index
	audio_play_sound(snd_button,0,0)
}