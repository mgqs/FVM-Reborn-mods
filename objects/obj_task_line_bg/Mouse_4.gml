if !instance_exists(obj_task_bg) exit
if btn_index < 0 || btn_index >= array_length(obj_task_bg.current_task_list) exit

if obj_task_bg.target_task_index != btn_index{
	var task_id = obj_task_bg.current_task_list[btn_index].id
	// 卡片情报任务的「已查看」只由情报岛点开卡片来写（card_info_task_complete），
	// 在任务看板里点一下行不算看过，否则红点会在真去看情报之前就消失
	if get_task_state(task_id) == "new" && card_info_task_card_id(task_id) == ""{
		edit_task_state(task_id,"viewed")
	}
	obj_task_bg.target_task_index = btn_index
	global.audio.play(snd_button,0,0)
}